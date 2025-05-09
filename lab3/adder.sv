`timescale 1ns/10ps

module adder (
	cout, sum,
	a, b, cin
);

	input logic a, b, cin;
	output logic cout, sum;
	
	// sum = a ^ b ^ cin
	// carry_out = (a & b) | (a & cin) | (b & cin)
	
	logic a_xor_b;
	xor #50 g1 (a_xor_b, a, b);
	xor #50 g2 (sum, a_xor_b, cin);
	
	logic ab, acin, bcin;
	and #50 g3 (ab, a, b);
	and #50 g4 (acin, a, cin);
	and #50 g5 (bcin, b, cin);
	or #50 g6 (cout, ab, acin, bcin);

endmodule
