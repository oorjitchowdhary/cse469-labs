`timescale 1ps/1ps

module register_1bit (q, d, clk, enable, reset);
    output logic q;
    input logic d;
    input logic clk, enable, reset;

    logic mux_result, not_enable, sel_d, sel_q;

    not #50 invert_enable(not_enable, enable);
    and #50 and_d(sel_d, d, enable);
    and #50 and_q(sel_q, q, not_enable);
    or  #50 or_mux(mux_result, sel_d, sel_q);

    D_FF dff (.q(q), .d(mux_result), .clk(clk), .reset(reset));
endmodule
