`timescale 1ps/1ps

module register_64bit (q, d, clk, enable, reset);
	output logic [63:0] q;
	input logic [63:0] d;
	input logic clk, enable, reset;
	
	logic [63:0] next_d;
	
	genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin : gen_register_bits
			// behavioral logic to implement: next_d[i] = enable ? d[i] : q[i]
			logic mux_result;
			
			logic not_enable;
			not #50 invert_enable (not_enable, enable);
			
			logic sel_d, sel_q;
			and #50 and_d (sel_d, d[i], enable); // use sel_d if both enable and d[i]
			and #50 and_q (sel_q, q[i], not_enable); // use sel_q if both q[i] and not enable
			
			// choose between sel_d or sel_q
			or #50 or_mux (mux_result, sel_d, sel_q);
			assign next_d[i] = mux_result;
			
			D_FF dff_i (.q(q[i]), .d(next_d[i]), .reset(reset), .clk(clk));
		end
	endgenerate
endmodule
