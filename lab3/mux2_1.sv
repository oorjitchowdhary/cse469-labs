module mux2_1 (out, i0, i1, sel);
	output logic out;
	input logic i0, i1, sel;
	
	assign out = (i0 & ~sel) | (i1 & sel);
endmodule

module mux2_1_testbench();
  logic i0, i1, sel;
  logic out;

  mux2_1 dut (.out(out), .i0(i0), .i1(i1), .sel(sel));

  integer i;
  initial begin
    for (i = 0; i < 8; i++) begin
      {sel, i0, i1} = i; #10;
    end
  end
endmodule
