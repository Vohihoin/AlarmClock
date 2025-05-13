module sec_counter(
    input clk,
    input reset_sync,
    output inc,
    output[25:0] count
);

    logic [25:0] reg_input;
    assign reg_input = (reset_sync) ? 26'b00000000000000000000000000 : count + 1'b1;
    d_ff count_reg[25:0](.clk(clk), .D(reg_input), .Q(count), .CLRN(1'b1), .PRN(1'b1));

    assign inc = (count == 47999999); // this assumes a 48MHz clock cycle and measures a second using that number of cycles
                                      // the reason we inc just before we hit that number of seconds is because we would want to increment
                                      // our seconds position as soon as we hit 50000000 clock cycles so the command to increment has to sent 
                                      // just before this. 

endmodule