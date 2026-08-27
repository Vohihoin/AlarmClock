module bcd7seg(
  input wire	[3:0] num,		// BCD number to display
  output wire	[6:0] seg		// seg[0]=A, seg[1]=B, ...
);

  ////////////////////////////////////////
  // Instantiate the 7 segment drivers //
  //////////////////////////////////////
  segAdec iA(.D(num),.segA(seg[0]));
  segBdec iB(.D(num),.segB(seg[1]));
  segCdec iC(.D(num),.segC(seg[2]));
  segDdec iD(.D(num),.segD(seg[3]));
  segEdec iE(.D(num),.segE(seg[4]));
  segFdec iF(.D(num),.segF(seg[5]));
  segGdec iG(.D(num),.segG(seg[6]));

endmodule  