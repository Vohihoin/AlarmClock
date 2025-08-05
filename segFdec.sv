// note that this is NOT a program - it is a hardware description that gets turned into logic!

module segFdec
(
	input [3:0] D,
	output segF
);

reg [0:15] truth_table = 16'b0111_0001_0011_1111;

assign segF = !truth_table[D];

endmodule
