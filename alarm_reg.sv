
module alarm_reg(
    output wire [3:0] Q,
    input wire inc,
    input wire resetn,
    input wire active,
    input wire clk
);

    
    logic [3:0] reg_input;
    logic load, inc_input;

    /* so when resetn is active (low), we load in 0000 synchronously */
    assign reg_input = 4'b0000;
    assign load = !resetn && active;
    
    /* The active input tells us when we're able to reset and load*/
    /* If it's inactive, our value just stays the same */
    assign inc_input = inc && active;

    reg4bit register(.Q(Q), .D(reg_input), .inc(inc_input), .load(load), .clk(clk));


endmodule