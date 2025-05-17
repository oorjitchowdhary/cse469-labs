module mux32_1_64bit (
	out,
	i0, i1, i2, i3, i4, i5, i6, i7,
	i8, i9, i10, i11, i12, i13, i14, i15,
	i16, i17, i18, i19, i20, i21, i22, i23,
	i24, i25, i26, i27, i28, i29, i30, i31,
	sel
);

	output logic [63:0] out;
	input logic [63:0] i0, i1, i2, i3, i4, i5, i6, i7,
							 i8, i9, i10, i11, i12, i13, i14, i15,
							 i16, i17, i18, i19, i20, i21, i22, i23,
							 i24, i25, i26, i27, i28, i29, i30, i31;
	input logic [4:0] sel;
	
	genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin : gen_muxes
			mux32_1 mux_i (
				.out(out[i]),
				.i0(i0[i]), .i1(i1[i]), .i2(i2[i]), .i3(i3[i]), .i4(i4[i]), .i5(i5[i]), .i6(i6[i]), .i7(i7[i]),
				.i8(i8[i]), .i9(i9[i]), .i10(i10[i]), .i11(i11[i]), .i12(i12[i]), .i13(i13[i]), .i14(i14[i]), .i15(i15[i]),
				.i16(i16[i]), .i17(i17[i]), .i18(i18[i]), .i19(i19[i]), .i20(i20[i]), .i21(i21[i]), .i22(i22[i]), .i23(i23[i]),
				.i24(i24[i]), .i25(i25[i]), .i26(i26[i]), .i27(i27[i]), .i28(i28[i]), .i29(i29[i]), .i30(i30[i]), .i31(i31[i]),
				.sel0(sel[0]), .sel1(sel[1]), .sel2(sel[2]), .sel3(sel[3]), .sel4(sel[4])
			);
		end
	endgenerate
endmodule
