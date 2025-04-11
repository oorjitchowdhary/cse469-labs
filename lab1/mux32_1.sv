module mux32_1 (
	out,
	i0, i1, i2, i3, i4, i5, i6, i7,
	i8, i9, i10, i11, i12, i13, i14, i15,
	i16, i17, i18, i19, i20, i21, i22, i23,
	i24, i25, i26, i27, i28, i29, i30, i31,
	sel0, sel1, sel2, sel3, sel4
);
	
	output logic out;
	input logic i0, i1, i2, i3, i4, i5, i6, i7;
	input logic i8, i9, i10, i11, i12, i13, i14, i15;
	input logic i16, i17, i18, i19, i20, i21, i22, i23;
	input logic i24, i25, i26, i27, i28, i29, i30, i31;
	input logic sel0, sel1, sel2, sel3, sel4;
	
	logic out0, out1;
	
	mux16_1 m0 (
		.out(out0),
		.i0(i0), .i1(i1), .i2(i2), .i3(i3),
		.i4(i4), .i5(i5), .i6(i6), .i7(i7),
		.i8(i8), .i9(i9), .i10(i10), .i11(i11),
		.i12(i12), .i13(i13), .i14(i14), .i15(i15),
		.sel0(sel0), .sel1(sel1), .sel2(sel2), .sel3(sel3)
	);
	mux16_1 m1 (
		.out(out1),
		.i0(i16), .i1(i17), .i2(i18), .i3(i19),
		.i4(i20), .i5(i21), .i6(i22), .i7(i23),
		.i8(i24), .i9(i25), .i10(i26), .i11(i27),
		.i12(i28), .i13(i29), .i14(i30), .i15(i31),
		.sel0(sel0), .sel1(sel1), .sel2(sel2), .sel3(sel3)
	);
	
	mux2_1 m (.out(out), .i0(out0), .i1(out1), .sel(sel4));
endmodule

module mux32_1_testbench();
  logic i0, i1, i2, i3, i4, i5, i6, i7;
  logic i8, i9, i10, i11, i12, i13, i14, i15;
  logic i16, i17, i18, i19, i20, i21, i22, i23;
  logic i24, i25, i26, i27, i28, i29, i30, i31;
  logic sel0, sel1, sel2, sel3, sel4;
  logic out;

  mux32_1 dut (.out(out),
               .i0(i0), .i1(i1), .i2(i2), .i3(i3),
               .i4(i4), .i5(i5), .i6(i6), .i7(i7),
               .i8(i8), .i9(i9), .i10(i10), .i11(i11),
               .i12(i12), .i13(i13), .i14(i14), .i15(i15),
               .i16(i16), .i17(i17), .i18(i18), .i19(i19),
               .i20(i20), .i21(i21), .i22(i22), .i23(i23),
               .i24(i24), .i25(i25), .i26(i26), .i27(i27),
               .i28(i28), .i29(i29), .i30(i30), .i31(i31),
               .sel0(sel0), .sel1(sel1), .sel2(sel2), .sel3(sel3), .sel4(sel4));

  logic [31:0] inputs;
  integer i;

  initial begin
    inputs = 32'b10110011001100101011001101010110;
    {i0, i1, i2, i3, i4, i5, i6, i7,
     i8, i9, i10, i11, i12, i13, i14, i15,
     i16, i17, i18, i19, i20, i21, i22, i23,
     i24, i25, i26, i27, i28, i29, i30, i31} = inputs;

    for (i = 0; i < 32; i++) begin
      {sel4, sel3, sel2, sel1, sel0} = i; #10;
    end
  end
endmodule

