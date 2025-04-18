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

	// pass_b
	assign pass_b_result = B;

	// adder inst
	logic [63:0] add_temp;
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

	// and inst
	and_64bit and_inst (.A(A), .B(B), .out(and_result));

	// or inst
	or_64bit or_inst (.A(A), .B(B), .out(or_result));

	// xor inst
	xor_64bit xor_inst (.A(A), .B(B), .out(xor_result));

	// ALU output based on cntrl
	always_comb begin
		case (cntrl)
			3'b000: result = pass_b_result;
			3'b010: result = add_result;
			3'b011: result = sub_result;
			3'b100: result = and_result;
			3'b101: result = or_result;
			3'b110: result = xor_result;
			default: result = 64'd0;
		endcase
	end

	// Flag logic
	always_comb begin
		zero = (result == 0);
		negative = result[63];

		// carry out and overflow matter only for add and subtract
		case (cntrl)
			3'b010: begin
				carry_out = add_cout;
				overflow = add_overflow;
			end
			3'b011: begin
				carry_out = sub_cout;
				overflow = sub_overflow;
			end
			default: begin
				carry_out = 0;
				overflow = 0;
			end
		endcase
	end

endmodule
