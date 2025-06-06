module mux16_1 (
	out,
	i0, i1, i2, i3, i4, i5, i6, i7,
	i8, i9, i10, i11, i12, i13, i14, i15,
	sel0, sel1, sel2, sel3
);

	output logic out;
	input logic i0, i1, i2, i3, i4, i5, i6, i7, i8;
	input logic i9, i10, i11, i12, i13, i14, i15;
	input logic sel0, sel1, sel2, sel3;
	
	logic out0, out1;
	
	mux8_1 m0 (
		.out(out0),
		.i0(i0), .i1(i1), .i2(i2), .i3(i3),
		.i4(i4), .i5(i5), .i6(i6), .i7(i7),
		.sel0(sel0), .sel1(sel1), .sel2(sel2)
	);
	mux8_1 m1 (
		.out(out1),
		.i0(i8), .i1(i9), .i2(i10), .i3(i11),
		.i4(i12), .i5(i13), .i6(i14), .i7(i15),
		.sel0(sel0), .sel1(sel1), .sel2(sel2)
	);
	
	mux2_1 m (.out(out), .i0(out0), .i1(out1), .sel(sel3));
endmodule

module mux16_1_testbench();
  logic i0, i1, i2, i3, i4, i5, i6, i7;
  logic i8, i9, i10, i11, i12, i13, i14, i15;
  logic sel0, sel1, sel2, sel3;
  logic out;

  mux16_1 dut (.out(out),
               .i0(i0), .i1(i1), .i2(i2), .i3(i3),
               .i4(i4), .i5(i5), .i6(i6), .i7(i7),
               .i8(i8), .i9(i9), .i10(i10), .i11(i11),
               .i12(i12), .i13(i13), .i14(i14), .i15(i15),
               .sel0(sel0), .sel1(sel1), .sel2(sel2), .sel3(sel3));

  integer i;
  initial begin
    {i0, i1, i2, i3, i4, i5, i6, i7,
     i8, i9, i10, i11, i12, i13, i14, i15} = 16'b1001011001101001;

    for (i = 0; i < 16; i++) begin
      {sel3, sel2, sel1, sel0} = i; #10;
    end
  end
endmodule
