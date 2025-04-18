module not_64bit (in, out);
	input logic [63:0] in;
	output logic [63:0] out;
	
	genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin
			not n (out[i], in[i]);
		end
	endgenerate
endmodule
