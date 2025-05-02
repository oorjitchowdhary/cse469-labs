// 64 bit program counter

module pc_64bit (clk, reset, next_pc, pc);
	input logic clk, reset;
	input logic [63:0] next_pc;
	output logic [63:0] pc;
	
	genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin : pc_bits
			D_FF dff_i (.q(pc[i]), .d(next_pc[i]), .reset(reset), .clk(clk));
		end
	endgenerate
endmodule
