module reg4bit(
    output [3:0] Q,
    input [3:0] D,
    input wire inc,
    input wire load,
    input wire clk
);

    logic [3:0] Lout;
    reg_cell reg4bit[3:0](.inc(inc), .load(load), .clk(clk), .D(D), .Q(Q), .Lout(Lout), .Rin({Lout[2:0],1'b1}));

endmodule