// 32 bit program counter

module pc (
	input logic clk,
	input logic reset,
	input logic [31:0] next_pc,
	output logic [31:0] curr_pc
);
	genvar i;
	generate
		for (i = 0; i < 32; i = i + 1) begin : pc_bits
			D_FF dff_i (.q(curr_pc[i]), .d(next_pc[i]), .reset(reset), .clk(clk));
		end
	endgenerate
endmodule
