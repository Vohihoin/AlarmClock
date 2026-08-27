module bcd7seg_en(
  input wire en,
  input wire	[3:0] num,		// BCD number to display
  output wire	[6:0] seg		// seg[0]=A, seg[1]=B, ...
);

  logic [6:0] raw_seg;
  bcd7seg mySeg(.num(num), .seg(raw_seg));

  assign seg = ~raw_seg & {7{en}};

endmodule