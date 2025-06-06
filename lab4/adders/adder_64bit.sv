`timescale 1ps/1ps

module adder_64bit (
	a, b, cin,
	sum, cout,
	overflow
);

	input logic [63:0] a, b;
	input logic cin;
	output logic [63:0] sum;
	output logic cout;
	output logic overflow;
	
	logic [63:0] carries;
	
	// pass cin to LSB calculation
	adder a0 (.a(a[0]), .b(b[0]), .cin(cin), .sum(sum[0]), .cout(carries[0]));
	
	// loop for bits between LSB and MSB
	genvar i;
	generate
		for (i = 1; i < 63; i = i + 1) begin: add_loop
			adder ai (.a(a[i]), .b(b[i]), .cin(carries[i-1]), .sum(sum[i]), .cout(carries[i]));
		end
	endgenerate
	
	// output cout from MSB calculation
	adder a63 (.a(a[63]), .b(b[63]), .cin(carries[62]), .sum(sum[63]), .cout(cout));

	// overflow = (MSB cin) xor (MSB cout)
	xor #50 overflow_xor (overflow, carries[62], cout);
endmodule
