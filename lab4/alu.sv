`timescale 1ps/1ps

module alu (
	input  logic [63:0] A, B,
	input  logic [2:0]  cntrl,
	output logic [63:0] result,
	output logic negative, zero, overflow, carry_out
);

	// decoder to select operation
	logic [7:0] sel;
	decoder_3to8 decoder_inst (
		.in(cntrl),
		.enable(1'b1),
		.out(sel)
	);

	// operation results
	logic [63:0] pass_b_result, add_result, sub_result;
	logic [63:0] and_result, or_result, xor_result;

	// flags from ops
	logic add_cout, add_overflow;
	logic sub_cout, sub_overflow;

	// 000 (sel[0]): pass B
	assign pass_b_result = B;

	// 010 (sel[2]): A + B
	adder_64bit add_inst (
		.a(A), .b(B), .cin(1'b0),
		.sum(add_result), .cout(add_cout), .overflow(add_overflow)
	);

	// 011 (sel[3]): A - B
	subtractor_64bit sub_inst (
		.A(A), .B(B),
		.diff(sub_result), .cout(sub_cout), .overflow(sub_overflow)
	);

	// 100 (sel[4]): bitwise AND
	and_64bit and_inst (.A(A), .B(B), .out(and_result));

	// 101 (sel[5]): bitwise OR
	or_64bit  or_inst  (.A(A), .B(B), .out(or_result));

	// 110 (sel[6]): bitwise XOR
	xor_64bit xor_inst (.A(A), .B(B), .out(xor_result));

	// assign final result
	logic [63:0] selected_pass_b, selected_add, selected_sub;
	logic [63:0] selected_and, selected_or, selected_xor;

	genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin : selected_result
			and #50 g0 (selected_pass_b[i], pass_b_result[i], sel[0]);
			and #50 g1 (selected_add[i], add_result[i], sel[2]);
			and #50 g2 (selected_sub[i], sub_result[i], sel[3]);
			and #50 g3 (selected_and[i], and_result[i], sel[4]);
			and #50 g4 (selected_or[i], or_result[i], sel[5]);
			and #50 g5 (selected_xor[i], xor_result[i], sel[6]);

			or #50 g6 (result[i],
				selected_pass_b[i], selected_add[i], selected_sub[i],
				selected_and[i], selected_or[i], selected_xor[i]
			);
		end
	endgenerate

	// assign flags
	// negative = MSB of result
	assign negative = result[63];

	// carry_out = (sel[2] & add_cout) | (sel[3] & sub_cout)
	logic selected_add_cout, selected_sub_cout;
	and #50 add_cout_and (selected_add_cout, sel[2], add_cout);
	and #50 sub_cout_and (selected_sub_cout, sel[3], sub_cout);
	or #50 or_cout (carry_out, selected_add_cout, selected_sub_cout);

	// overflow = (sel[2] & add_overflow) | (sel[3] & sub_overflow)
	logic selected_add_overflow, selected_sub_overflow;
	and #50 add_overflow_and (selected_add_overflow, sel[2], add_overflow);
	and #50 sub_overflow_and (selected_sub_overflow, sel[3], sub_overflow);
	or #50 or_overflow (overflow, selected_add_overflow, selected_sub_overflow);

	// zero = result == 0
	zero_64bits zero_alu (.in(result), .zero(zero));

endmodule
