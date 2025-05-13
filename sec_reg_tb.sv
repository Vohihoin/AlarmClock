module sec_reg_tb();

    reg clk;
    reg reset;
    reg set;
    reg inc_sec;
    reg[3:0] inputVal;
    wire[3:0] reg_output;
    wire hit9;
    sec_reg_U iDUT(.clk(clk), .reset(reset), .set(set), .new_val(inputVal), .Q(reg_output), .hit9(hit9), .inc_sec(inc_sec));

    initial begin

        clk = 1'b0;
        reset = 1'b1;
        set = 1'b0;
        inputVal = 4'b1011;
        inc_sec = 1'b0;

        @(negedge clk)
        if (reg_output != 4'b0000) begin
            $display("Output should be 0000");
        end

        reset = 1'b0;
        set = 1'b1;

        @(negedge clk)
        if (reg_output != 4'b1011) begin
            $display("Output should be 1011");
        end

        set = 1'b0;
        inc_sec = 1'b1;

        @(negedge clk)
        if (reg_output != 4'b1100) begin
            $display("Output should be 1100");
        end

        @(negedge clk)
        if (reg_output != 4'b1101) begin
            $display("Output should be 1101");
        end

        @(negedge clk)
        if (reg_output != 4'b1110) begin
            $display("Output should be 1110");
        end

        inc_sec = 1'b0;

        @(negedge clk)
        if (reg_output != 4'b1110) begin
            $display("Output should be 1110");
        end

        inc_sec = 1'b1;

        $display("YAHOO! Cool Beans");

    end

    always
        #5 clk = ~clk;

endmodule