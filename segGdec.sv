module segGdec
(
	input [3:0] D, // input is D
	output segG
);

  //////////////////////////////////////////
  // Declare any needed internal signals //
  ////////////////////////////////////////
  logic notD3, notD2, notD1;
  logic originalSegG;
  logic prodTerm1, prodTerm2;

  
  //////////////////////////////////////////////////////
  // Write STRUCTURAL verilog to implement segment G //
  ////////////////////////////////////////////////////
  not not1(notD1, D[1]);
  not not2(notD2, D[2]);
  not not3(notD3, D[3]);

  and and1(prodTerm1, notD3, notD2, notD1);
  and and2(prodTerm2, notD3, D[2], D[1], D[0]);
  or or1(originalSegG, prodTerm1, prodTerm2);
  assign segG = !originalSegG;
  
endmodule
