module reg6bit(
    input [5:0] D,
    output [5:0] Q,
    input wire clk,
    input resetn
);

    d_ff iREG[5:0](.clk(clk), .D(D), .Q(Q), .CLRN(resetn), .PRN(1'b1));

endmodule