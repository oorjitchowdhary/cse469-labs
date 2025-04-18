module alu (
	input  logic [63:0] A, B,
	input  logic [2:0]  cntrl,
	output logic [63:0] result,
	output logic negative, zero, overflow, carry_out
);

	// intermediate variables
	logic [63:0] pass_b_result, add_result, sub_result, and_result, or_result, xor_result;
	logic add_cout, sub_cout;
	logic add_overflow, sub_overflow;

	// decoder output
	logic [7:0] sel;

	// decoder inst
	decoder_3to8 decoder_inst (
		.in(cntrl),
		.out(sel)
	);

	// pass_b
	assign pass_b_result = B;

	// adder inst
	adder_64bit add_inst (
		.a(A), .b(B), .cin(1'b0),
		.sum(add_result), .cout(add_cout)
	);
	assign add_overflow = (A[63] == B[63]) && (add_result[63] != A[63]);

	// subtractor inst
	subtractor_64bit sub_inst (
		.A(A), .B(B),
		.diff(sub_result), .cout(sub_cout)
	);
	assign sub_overflow = (A[63] != B[63]) && (sub_result[63] != A[63]);

	// logic gates
	and_64bit and_inst (.A(A), .B(B), .out(and_result));
	or_64bit  or_inst  (.A(A), .B(B), .out(or_result));
	xor_64bit xor_inst (.A(A), .B(B), .out(xor_result));

	// use sel signals to mux the result using AND-OR logic
	genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin : result_mux
			assign result[i] = (pass_b_result[i] & sel[0]) |
			                   (add_result[i]     & sel[2]) |
			                   (sub_result[i]     & sel[3]) |
			                   (and_result[i]     & sel[4]) |
			                   (or_result[i]      & sel[5]) |
			                   (xor_result[i]     & sel[6]);
		end
	endgenerate

	// flags
	assign negative = result[63];

	// zero flag = NOR tree of result bits
	logic [63:0] result_inv;
	genvar j;
	generate
		for (j = 0; j < 64; j = j + 1) begin : zero_gen
			not (result_inv[j], result[j]);
		end
	endgenerate
	assign zero = &result_inv;

	// overflow and carry_out (only valid for ADD and SUB)
	assign carry_out = (sel[2] & add_cout) | (sel[3] & sub_cout);
	assign overflow  = (sel[2] & add_overflow) | (sel[3] & sub_overflow);

endmodule
