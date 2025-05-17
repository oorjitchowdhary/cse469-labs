`timescale 1ps/1ps

module xor_64bit (A, B, out);
	input logic [63:0] A, B;
	output logic [63:0] out;
	
	genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin: xor_loop
			xor #50 a_xor_b (out[i], A[i], B[i]);
		end
	endgenerate
endmodule
