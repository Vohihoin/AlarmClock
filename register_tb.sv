module register_tb(); 

    reg[3:0] D;
    reg inc, load, clk;

    wire[3:0] Q;

    reg4bit iDUT(.D(D), .Q(Q), .inc(inc), .load(load), .clk(clk));

    initial begin

        clk = 1'b0;
        inc = 1'b0;
        load = 1'b1;
        D = 4'b0000;

        @(negedge clk);

        load = 1'b0;
        inc = 1'b1;

        @(negedge clk);

        if (Q != 4'h1) begin
            $display("Should be 0001");
            $stop();
        end

        @(negedge clk);

        if (Q != 4'h2) begin
            $display("Should be 0010");
            $stop();
        end

        $display("YAHOO! All tests passed");

    end

    always 
        #5 clk = ~clk;

endmodule
