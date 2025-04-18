module adder_64bit (
	a, b, cin,
	sum, cout
);

	input logic [63:0] a, b;
	input logic cin;
	output logic [63:0] sum;
	output logic cout;
	
	logic [63:0] carrys;
	
	// pass cin to LSB calculation
	adder a0 (.a(a[0]), .b(b[0]), .cin(cin), .sum(sum[0]), .cout(carrys[0]));
	
	// loop for bits between LSB and MSB
	genvar i;
	generate
		for (i = 1; i < 63; i = i + 1) begin: add_loop
			adder ai (.a(a[i]), .b(b[i]), .cin(carrys[i-1]), .sum(sum[i]), .cout(carrys[i]));
		end
	endgenerate
	
	// output cout from MSB calculation
	adder a63 (.a(a[63]), .b(b[63]), .cin(carrys[62]), .sum(sum[63]), .cout(cout));
endmodule
