module mux32_64bit (
	out,
	in0, in1, in2, in3, in4, in5, in6, in7,
	in8, in9, in10, in11, in12, in13, in14, in15,
	in16, in17, in18, in19, in20, in21, in22, in23,
	in24, in25, in26, in27, in28, in29, in30, in31,
	sel
);

	output logic [63:0] out;
	input logic [63:0] in0, in1, in2, in3, in4, in5, in6, in7,
							 in8, in9, in10, in11, in12, in13, in14, in15,
							 in16, in17, in18, in19, in20, in21, in22, in23,
							 in24, in25, in26, in27, in28, in29, in30, in31;
	input logic [4:0] sel;
	
	genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin : gen_muxes
			mux32_1 mux_i (
				.out(out[i]),
				.i0(in0[i]), .i1(in1[i]), .i2(in2[i]), .i3(in3[i]), .i4(in4[i]), .i5(in5[i]), .i6(in6[i]), .i7(in7[i]),
				.i8(in8[i]), .i9(in9[i]), .i10(in10[i]), .i11(in11[i]), .i12(in12[i]), .i13(in13[i]), .i14(in14[i]), .i15(in15[i]),
				.i16(in16[i]), .i17(in17[i]), .i18(in18[i]), .i19(in19[i]), .i20(in20[i]), .i21(in21[i]), .i22(in22[i]), .i23(in23[i]),
				.i24(in24[i]), .i25(in25[i]), .i26(in26[i]), .i27(in27[i]), .i28(in28[i]), .i29(in29[i]), .i30(in30[i]), .i31(in31[i]),
				.sel0(sel[0]), .sel1(sel[1]), .sel2(sel[2]), .sel3(sel[3]), .sel4(sel[4])
			);
		end
	endgenerate
endmodule
