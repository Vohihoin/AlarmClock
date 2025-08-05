// note that this is NOT a program - it is a hardware description that gets turned into logic!

module segBdec
(
	input [3:0] D,
	output segB
);

reg [0:15] truth_table = 16'b0000_0110_0011_1111;


assign segB = !truth_table[D];

endmodule
