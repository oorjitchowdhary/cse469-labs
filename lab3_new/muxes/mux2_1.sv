`timescale 1ps/1ps

module mux2_1 (out, i0, i1, sel);
	output logic out;
	input logic i0, i1, sel;
	
	logic sel_n, out0, out1;
	
	not #50 n (sel_n, sel);
	and #50 a0 (out0, i0, sel_n); // i0 & ~sel
	and #50 a1 (out1, i1, sel); // i1 & sel
	
	or #50 or_out (out, out0, out1);
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
