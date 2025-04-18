// Test bench for ALU
`timescale 1ns/10ps

// Meaning of signals in and out of the ALU:

// Flags:
// negative: whether the result output is negative if interpreted as 2's comp.
// zero: whether the result output was a 64-bit zero.
// overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
// carry_out: on an add or subtract, whether the computation produced a carry-out.

// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant

module alustim();

	parameter delay = 100000;

	logic		[63:0]	A, B;
	logic		[2:0]		cntrl;
	logic		[63:0]	result;
	logic					negative, zero, overflow, carry_out ;

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
	

	alu dut (.A, .B, .cntrl, .result, .negative, .zero, .overflow, .carry_out);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	integer i;
	logic [63:0] test_val;
	initial begin
	
		$display("%t testing PASS_B operations", $time);
		cntrl = ALU_PASS_B;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end
		
		$display("%t testing addition", $time);
		cntrl = ALU_ADD;
		//pos + pos = pos (1 + 1 = 2)
		A = 64'h0000000000000001; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h0000000000000002 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		
		//neg + neg = neg (-1 + -2 = -3)
		A = -64'sd1; B = -64'sd2;
		#(delay);
		assert(result == -64'sd5 && carry_out == 1 && overflow == 0 && negative == 1 && zero == 0);
		
		//neg + pos = 0 (-5 + 5 = 0)
		A = -64'sd5; B = 64'sd5;
		#(delay);
		assert(result == 64'sd0 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 1);
		
		// pos + neg = neg (1 + -5 = -4)
		A = 64'd1; B = -64'd5;
		#(delay);
		assert(result == -64'd4 && carry_out == 1 && overflow == 0 && negative == 1 && zero == 0);
		
		//MAX + 1 = MIN (overflow but no carry out)
		A = 64'h7FFFFFFFFFFFFFFF; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h8000000000000000 && carry_out == 0 && overflow == 1 && negative == 1 && zero == 0);
		
		//MIN + -1 = MAX (overflow and carry out)
		A = 64'h8000000000000000; B = 64'hFFFFFFFFFFFFFFFF;
		#(delay);
		assert(result == 64'h7FFFFFFFFFFFFFFF && carry_out == 1 && overflow == 1 && negative == 0 && zero == 0);
		
		// large pos + small pos = MAX (no overflow)
		A = 64'h7FFFFFFFFFFFFFFE; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h7FFFFFFFFFFFFFFF && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		
		// large neg + small neg = MIN (no overflow but carry out)
		A = 64'h8000000000000001; B = 64'hFFFFFFFFFFFFFFFF; 
		#(delay);
		assert(result == 64'h8000000000000000 && carry_out == 1 && overflow == 0 && negative == 1 && zero == 0);
		
		// MAX + 1 = 0 (carry out)
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h0000000000000000 && carry_out == 1 && overflow == 0 && negative == 0 && zero == 1);
		
		$display("%t testing subtraction", $time);
		cntrl = ALU_SUBTRACT;
		
		// pos - pos = pos (5 - 3 = 2)
		A = 64'd5; B = 64'd3;
		#(delay);
		assert(result == 64'd2 && carry_out == 1 && overflow == 0 && negative == 0 && zero == 0);

		// pos - pos = neg (3 - 5 = -2)
		A = 64'd3; B = 64'd5;
		#(delay);
		assert(result == -64'd2 && carry_out == 0 && overflow == 0 && negative == 1 && zero == 0);

		// neg - pos = neg (-5 - 3 = -8)
		A = -64'd5; B = 64'd3;
		#(delay);
		assert(result == -64'd8 && carry_out == 0 && overflow == 0 && negative == 1 && zero == 0);

		// pos - neg = pos (5 - (-3) = 8)
		A = 64'd5; B = -64'd3;
		#(delay);
		assert(result == 64'd8 && carry_out == 1 && overflow == 0 && negative == 0 && zero == 0);
		
		// pos - neg = neg (1 - 2 = -1)
		A = 64'd1; B = 64'd2;
		#(delay);
		assert(result == -64'd1 && carry_out == 0 && overflow == 0 && negative == 1 && zero == 0);

		// neg - neg = pos (-3 - (-5) = 2)
		A = -64'd3; B = -64'd5;
		#(delay);
		assert(result == 64'd2 && carry_out == 1 && overflow == 0 && negative == 0 && zero == 0);

		// neg - neg = neg (-5 - (-3) = -2)
		A = -64'd5; B = -64'd3;
		#(delay);
		assert(result == -64'd2 && carry_out == 0 && overflow == 0 && negative == 1 && zero == 0);

		// pos - pos = 0 (1234 - 1234 = 0)
		A = 64'd1234; B = 64'd1234;
		#(delay);
		assert(result == 64'd0 && carry_out == 1 && overflow == 0 && negative == 0 && zero == 1);

		// MAX - (-1) = overflow
		A = 64'h7FFFFFFFFFFFFFFF; B = -64'd1;
		#(delay);
		assert(result == 64'h8000000000000000 && overflow == 1 && negative == 1 && zero == 0);

		// MIN - 1 = overflow
		A = 64'h8000000000000000; B = 64'd1;
		#(delay);
		assert(result == 64'h7FFFFFFFFFFFFFFF && overflow == 1 && negative == 0 && zero == 0);

		$display("%t testing bitwise AND", $time);
		cntrl = ALU_AND;
		
		// all ones & all zeroes = 0
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'h0000000000000000;
		#(delay);
		assert(result == 64'h0000000000000000 && zero == 1 && negative == 0);
		
		//MSB & MSB = MSB
		A = 64'h8000000000000000; B = 64'h8000000000000000;
		#(delay);
		assert(result == 64'h8000000000000000 && negative == 1 && zero == 0);
		
		//all 1s & all 1s = all 1s
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFF;
		#(delay);
		assert(result == 64'hFFFFFFFFFFFFFFFF && zero == 0 && negative == 1);

		$display("%t testing bitwise OR", $time);
		cntrl = ALU_OR;

		//0 | anything = 0
		A = 64'h0000000000000000; B = 64'h0F0F0F0F0F0F0F0F;
		#(delay);
		assert(result == (A | B) && negative == 0 && zero == 0);

		//alternating pattern = all 1s
		A = 64'hF0F0F0F0F0F0F0F0; B = 64'h0F0F0F0F0F0F0F0F;
		#(delay);
		assert(result == 64'hFFFFFFFFFFFFFFFF && negative == 1 && zero == 0);

		//0 | 0 = 0 
		A = 64'h0000000000000000; B = 64'h0000000000000000;
		#(delay);
		assert(result == 64'h0000000000000000 && zero == 1 && negative == 0);

		$display("%t testing bitwise XOR", $time);
		cntrl = ALU_XOR;

		// alternating A and B = all 1s
		A = 64'hAAAAAAAAAAAAAAAA; B = 64'h5555555555555555;
		#(delay);
		assert(result == 64'hFFFFFFFFFFFFFFFF && negative == 1 && zero == 0);

		// A xor B = 0
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFF;
		#(delay);
		assert(result == 64'h0000000000000000 && zero == 1 && negative == 0);

		// MSB ^ LSB = MSB
		A = 64'h8000000000000000; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h8000000000000001 && negative == 1 && zero == 0);

		// random A ^ B
		A = 64'h123456789ABCDEF0; B = 64'h0F0F0F0F0F0F0F0F;
		#(delay);
		assert(result == (A ^ B) && negative == result[63]);
		
	end
endmodule
