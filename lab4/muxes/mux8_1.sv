module mux8_1 (
	out,
	i0, i1, i2, i3, i4, i5, i6, i7,
	sel0, sel1, sel2
);
		
	output logic out;
	input logic i0, i1, i2, i3, i4, i5, i6, i7;
	input logic sel0, sel1, sel2;
		
	logic out0, out1;
	
	mux4_1 m0 (
		.out(out0),
		.i0(i0), .i1(i1), .i2(i2), .i3(i3),
		.sel0(sel0), .sel1(sel1)
	);
	mux4_1 m1 (
		.out(out1),
		.i0(i4), .i1(i5), .i2(i6), .i3(i7),
		.sel0(sel0), .sel1(sel1)
	);
	
	mux2_1 m (.out(out), .i0(out0), .i1(out1), .sel(sel2));
endmodule

module mux8_1_testbench();
  logic i0, i1, i2, i3, i4, i5, i6, i7;
  logic sel0, sel1, sel2;
  logic out;

  mux8_1 dut (.out(out),
              .i0(i0), .i1(i1), .i2(i2), .i3(i3),
              .i4(i4), .i5(i5), .i6(i6), .i7(i7),
              .sel0(sel0), .sel1(sel1), .sel2(sel2));

  integer i;
  initial begin
    {i0, i1, i2, i3, i4, i5, i6, i7} = 8'b01011011;
    for (i = 0; i < 8; i++) begin
      {sel2, sel1, sel0} = i; #10;
    end
  end
endmodule

