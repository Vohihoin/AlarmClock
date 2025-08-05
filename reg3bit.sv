module reg3bit(
    output [2:0] Q,
    input [2:0] D,
    input wire inc,
    input wire load,
    input wire clk
);

    logic [2:0] Lout;
    reg_cell reg4bit[2:0](.inc(inc), .load(load), .clk(clk), .D(D), .Q(Q), .Lout(Lout), .Rin({Lout[1:0],1'b1}));

endmodule