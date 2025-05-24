`timescale 1ps/1ps

module register_3bit (q, d, clk, enable, reset);
    output logic [2:0] q;
    input  logic [2:0] d;
    input  logic clk, enable, reset;

    logic [2:0] next_d;
    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin : reg_bits
            logic mux_result, not_enable, sel_d, sel_q;

            not #50 invert_enable(not_enable, enable);
            and #50 and_d(sel_d, d[i], enable);
            and #50 and_q(sel_q, q[i], not_enable);
            or  #50 or_mux(mux_result, sel_d, sel_q);

            assign next_d[i] = mux_result;
            D_FF dff_i (.q(q[i]), .d(next_d[i]), .clk(clk), .reset(reset));
        end
    endgenerate
endmodule
