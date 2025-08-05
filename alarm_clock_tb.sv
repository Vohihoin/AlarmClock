module alarm_clock_tb();

    reg clk, reset;
    wire [3:0] secU, secT, minU, minT, hrU, hrT;
    wire [6:0] secUSeg, secTSeg, minUSeg, minTSeg, hrUSeg, hrTSeg;

    alarm_clock iDUT(.clk(clk), .reset(reset), .secU(secU), .secT(secT), .minU(minU), .minT(minT), .hrU(hrU), .hrT(hrT),
                     .secUSeg(secUSeg), .secTSeg(secTSeg), .minUSeg(minUSeg), .minTSeg(minTSeg), .hrUSeg(hrUSeg), .hrTSeg(hrTSeg));

    initial begin

        clk = 1'b0;
        reset = 1'b1;

        @(negedge clk);

        reset = 1'b0;



    end


    always
        #5 clk = ~clk;

endmodule