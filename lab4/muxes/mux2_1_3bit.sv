module mux2_1_3bit (
	output logic [2:0] out,
	input logic [2:0] i0,
	input logic [2:0] i1,
	input logic sel
);
	genvar k;
	generate
		for (k = 0; k < 3; k = k + 1) begin : mux_bit
			mux2_1 mux_inst (.out(out[k]), .i0(i0[k]), .i1(i1[k]), .sel(sel));
		end
	endgenerate
endmodule
