module mux4_1 (out, i0, i1, i2, i3, sel0, sel1);
	output logic out;
	input logic i0, i1, i2, i3, sel0, sel1;
	
	logic out0, out1;
	
	mux2_1 m0 (.out(out0), .i0(i0), .i1(i1), .sel(sel0));
	mux2_1 m1 (.out(out1), .i0(i2), .i1(i3), .sel(sel0));
	
	mux2_1 m (.out(out), .i0(out0), .i1(out1), .sel(sel1));
endmodule

module mux4_1_testbench();
  logic i0, i1, i2, i3, sel0, sel1;
  logic out;

  mux4_1 dut (.out(out), .i0(i0), .i1(i1), .i2(i2), .i3(i3), .sel0(sel0), .sel1(sel1));

  integer i;
  initial begin
    for (i = 0; i < 16; i++) begin
      {sel1, sel0, i0, i1} = i[3:0];
      {i2, i3} = 2'b10; #10;
    end
  end
endmodule
