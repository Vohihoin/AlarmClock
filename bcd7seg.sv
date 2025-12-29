module bcd7seg(
  input wire	[3:0] num,		// BCD number to display
  output wire	[6:0] seg		// seg[6]=A, seg[5]=B, ...
);

  ////////////////////////////////////////
  // Instantiate the 7 segment drivers //
  //////////////////////////////////////
  segAdec iA(.D(num),.segA(seg[6]));
  segBdec iB(.D(num),.segB(seg[5]));
  segCdec iC(.D(num),.segC(seg[4]));
  segDdec iD(.D(num),.segD(seg[3]));
  segEdec iE(.D(num),.segE(seg[2]));
  segFdec iF(.D(num),.segF(seg[1]));
  segGdec iG(.D(num),.segG(seg[0]));

endmodule  