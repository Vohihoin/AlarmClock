// note that this is NOT a program - it is a hardware description that gets turned into logic!

module segCdec
(
	input [3:0] D,
	output segC
);

reg [0:15] truth_table = 16'b0010_0000_0011_1111;

assign segC = !truth_table[D];

endmodule
