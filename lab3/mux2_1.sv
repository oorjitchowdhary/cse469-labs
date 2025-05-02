module mux2_1 (out, i0, i1, sel);
	output logic out;
	input logic i0, i1, sel;
	
	logic sel_n, out0, out1;
	
	not n (sel_n, sel);
	and a0 (out0, i0, sel_n); // i0 & ~sel
	and a1 (out1, i1, sel); // i1 & sel
	
	or or_out (out, out0, out1);
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
