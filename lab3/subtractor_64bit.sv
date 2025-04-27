module subtractor_64bit (A, B, diff, cout);
	input logic [63:0] A, B;
	output logic [63:0] diff;
	output logic cout;
	
	logic [63:0] B_inverted;
	not_64bit inv64 (.in(B), .out(B_inverted));
	
	// A - B = A + (-B)
	// -B = 2C form of B = bit flips + 1, so carry_in = 1
	
	adder_64bit subtractor (.a(A), .b(B_inverted), .cin(1'b1), .sum(diff), .cout(cout));
endmodule
