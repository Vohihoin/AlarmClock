module alarm_clock_last_tb(
);

    // WE ARE GOING FORWARD!!

    logic clk;
    logic rst_n;
    logic set_time;
    logic set_alarm;
    logic switch_sel;
    logic increment_in;

    logic [3:0] secU;
    logic [3:0] secT;
    logic [3:0] minU;
    logic [3:0] minT;
    logic [3:0] hrU;
    logic [3:0] hrT;

    logic [6:0] secUSeg;
    logic [6:0] secTSeg;
    logic [6:0] minUSeg;
    logic [6:0] minTSeg;
    logic [6:0] hrUSeg;
    logic [6:0] hrTSeg;

    logic alarm_ring;
    logic buzzer_pwm;

    alarm_clock_top_level iDUT(
        .clk(clk), 
        .rst_n(rst_n), 
        .set_time(set_time),
        .set_alarm(set_alarm),
        .switch_select(switch_sel),
        .increment_in(increment_in),

        .secU(secU),
        .secT(secT),
        .minU(minU),
        .minT(minT),
        .hrU(hrU),
        .hrT(hrT),

        .secUSeg(secUSeg), 
        .secTSeg(secTSeg), 
        .minUSeg(minUSeg), 
        .minTSeg(minTSeg), 
        .hrUSeg(hrUSeg), 
        .hrTSeg(hrTSeg), 

        .alarm_ring(alarm_ring), 
        .buzzer_pwm(buzzer_pwm)
    );

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        set_time = 1'b0;
        set_alarm = 1'b0;
        switch_sel = 1'b0;
        increment_in = 1'b0;

        @(posedge clk);
        @(negedge clk);

        rst_n = 1'b1;

        while (!((hrT === 1) && (hrU === 2))) @(negedge clk);

        $display("Yahoo!! Cool beans")
        $stop();

    end

    always 
        #5 clk = ~clk;


endmodule