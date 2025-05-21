module alarm_clock_tb();

    reg clk, reset;
    wire [3:0] secU, secT, minU, minT, hrU, hrT;

    alarm_clock iDUT(.clk(clk), .reset(reset), .secU(secU), .secT(secT), .minU(minU), .minT(minT), .hrU(hrU), .hrT(hrT));

    initial begin

        clk = 1'b0;
        reset = 1'b1;

        @(negedge clk);

        reset = 1'b0;



    end


    always
        #5 clk = ~clk;

endmodule