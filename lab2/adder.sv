module adder (
	cout, sum,
	a, b, cin
);

	input logic a, b, cin;
	output logic cout, sum;
	
	// sum = a ^ b ^ cin
	// carry_out = (a & b) | (a & cin) | (b & cin)
	
	logic a_xor_b;
	xor g1 (a_xor_b, a, b);
	xor g2 (sum, a_xor_b, cin);
	
	logic ab, acin, bcin;
	and g3 (ab, a, b);
	and g4 (acin, a, cin);
	and g5 (bcin, b, cin);
	or g6 (cout, ab, acin, bcin);

endmodule
