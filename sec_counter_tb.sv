module sec_counter_tb();

    reg clk;
    reg reset_sync;
    wire inc_out;
    wire[25:0] count;

    sec_counter iDUT(.clk(clk), .reset_sync(reset_sync), .inc(inc_out), .count(count));


    initial begin

        clk = 1'b0;
        reset_sync = 1'b1;

        @(negedge clk)

        reset_sync = 1'b0;

        @(inc_out)
        $display("Yay, sec reached");
        $display(count);
        $display($time);
        


    end

    always
        #10000 clk = ~clk; // 10000 picoseconds half time correspond to a 50MHz clock


endmodule