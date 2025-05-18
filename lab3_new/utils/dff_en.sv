module D_FF_en (
    output logic q,
    input logic d,
    input logic reset,
    input logic clk,
    input logic enable
);
    logic enabled_d;
    mux2_1 mux_inst (.out(enabled_d), .i0(q), .i1(d), .sel(enable));

    D_FF dff_inst (.q(q), .d(enabled_d), .reset(reset), .clk(clk));
endmodule
