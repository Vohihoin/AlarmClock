module reg1bit(
    input wire D,
    output wire Q,
    input wire clk,
    input resetn
);

    d_ff(.clk(clk), .D(D), .Q(Q), .CLRN(resetn), .PRN(1'b1));

endmodule