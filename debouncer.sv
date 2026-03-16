//fpga4student.com: FPGA projects, Verilog projects, VHDL projects
// Verilog code for button debouncing on FPGA
// debouncing module without creating another clock domain
// by using clock enable signal 

// Module basically double flops the signal and uses the clock_enable module to produce a slower "clock" that only 
// lets the flip flops sample once every couple of cycles
module debouncer
    #(parameter FAST_SIM = 1)
    (input pb_1,clk,output pb_out);

    wire slow_clk_en;
    wire Q1,Q2,Q2_bar,Q0;

    clock_enable #(FAST_SIM) u1(clk,slow_clk_en);
    my_dff_en d0(clk,slow_clk_en,pb_1,Q0);

    my_dff_en d1(clk,slow_clk_en,Q0,Q1);
    my_dff_en d2(clk,slow_clk_en,Q1,Q2);

    assign Q2_bar = ~Q2;
    assign pb_out = Q1 & Q2_bar & slow_clk_en; // pb_out is raised when we detect a rising edge in our input pb_1

endmodule

// Slow clock enable for debouncing button 
module clock_enable
    #(parameter FAST_SIM = 1)
    (input Clk_50M,output slow_clk_en);
        
    generate: set_count
        if (FAST_SIM)
            localparam MAX_COUNT = 13;
        else 
            localparam MAX_COUNT = 124999;
    endgenerate

    reg [26:0]counter=0;
    always @(posedge Clk_50M)
    begin
       counter <= (counter >= set_count.MAX_COUNT) ? 0 :counter+1; // actual counter value 124999 instead of 3
    end
    assign slow_clk_en = (counter == set_count.MAX_COUNT)?1'b1:1'b0;

endmodule

// D-flip-flop with clock enable signal for debouncing module 
module my_dff_en(input DFF_CLOCK, clock_enable,D, output reg Q=0);
    always @ (posedge DFF_CLOCK) begin
        if(clock_enable==1) 
           Q <= D;
    end
endmodule 