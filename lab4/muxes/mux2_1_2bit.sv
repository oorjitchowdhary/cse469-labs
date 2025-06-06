module mux2_1_2bit (
	output logic [1:0] out,
	input logic [1:0] i0,
	input logic [1:0] i1,
	input logic sel
);
	genvar k;
	generate
		for (k = 0; k < 2; k = k + 1) begin : mux_bit
			mux2_1 mux_inst (.out(out[k]), .i0(i0[k]), .i1(i1[k]), .sel(sel));
		end
	endgenerate
endmodule
