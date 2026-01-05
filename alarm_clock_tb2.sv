module alarm_clock_tb2(
);


    logic clk;
    logic resetn;
    logic set_time;
    logic switch_select_in;
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

    initial begin
        clk = 1'b0;
        resetn = 1'b0;
        set_time = 1'b0;
        switch_select_in = 1'b0;
        increment_in = 1'b0;


        @(negedge clk)

        @(negedge clk)
        resetn = 1'b1;


        // Test out debouncing
        #80
        increment_in = 1'b1;
        switch_select_in = 1'b1;
        #30
        increment_in = 1'b0;
        switch_select_in = 1'b0;

        // enter set time mode
        #150
        set_time = 1'b1;

        // select the third digit place - Minutes units place
        #10
        switch_select_in = 1'b1;
        #130
        switch_select_in = 1'b0;
                
        #30
        switch_select_in = 1'b1;
        #130
        switch_select_in = 1'b0;

        // try and increment the time
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;
        
        if (secU !== 4'b0001) begin
            $display("Set time mode didn't increment to 1");
        end

        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;
        
        if (secU !== 4'b0010) begin
            $display("Set time mode didn't increment to 2");
        end

        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;
        
        if (secU !== 3) begin
            $display("Set time mode didn't increment to 3");
        end

        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;

        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;

        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;

        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;

        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;

        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;

        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;

        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;

        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;

        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;

        switch_select_in = 1'b1;
        #130
        switch_select_in = 1'b0;

        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;

        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;

        switch_select_in = 1'b1;
        #130
        switch_select_in = 1'b0;

        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;

        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;

        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;

        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;

        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;


        switch_select_in = 1'b1;
        #130
        switch_select_in = 1'b0;

        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;

        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;

        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;

        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;


        #30
        increment_in = 1'b1;
        #120
        increment_in = 1'b0;


        set_time = 1'b0;
        


    end

    always #5 clk = ~clk; // period of 10

    alarm_clock iDUT(.clk(clk), .resetn(resetn), .set_time(set_time), .switch_select_in(switch_select_in), .increment_in(increment_in),
            .secU(secU), .secT(secT), .minU(minU), .minT(minT), .hrU(hrU), .hrT(hrT), .secUSeg(secUSeg), .secTSeg(secTSeg), .minUSeg(minUSeg),
            .minTSeg(minTSeg), .hrUSeg(hrUSeg), .hrTSeg(hrTSeg));



endmodule