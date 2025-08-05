// note that this is NOT a program - it is a hardware description that gets turned into logic!

module segEdec
(
	input [3:0] D,
	output segE
);

reg [0:15] truth_table = 16'b0101_1101_0111_1111;

assign segE = !truth_table[D];

endmodule
