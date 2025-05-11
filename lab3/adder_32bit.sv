module adder_32bit (
	a, b, cin,
	sum, cout
);

	input logic [31:0] a, b;
	input logic cin;
	output logic [31:0] sum;
	output logic cout;

	logic [31:0] carrys;

	// pass cin to LSB calculation
	adder a0 (.a(a[0]), .b(b[0]), .cin(cin), .sum(sum[0]), .cout(carrys[0]));

	// loop for bits between LSB and MSB
	genvar i;
	generate
		for (i = 1; i < 31; i = i + 1) begin: add_loop
			adder ai (.a(a[i]), .b(b[i]), .cin(carrys[i-1]), .sum(sum[i]), .cout(carrys[i]));
		end
	endgenerate

	// output cout from MSB calculation
	adder a31 (.a(a[31]), .b(b[31]), .cin(carrys[30]), .sum(sum[31]), .cout(cout));

endmodule
