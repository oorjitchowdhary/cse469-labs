`timescale 1ps/1ps

module register_5bit (q, d, clk, enable, reset);
    output logic [4:0] q;
    input logic [4:0] d;
    input logic clk, enable, reset;

    genvar i;
    generate
        for (i = 0; i < 5; i = i + 1) begin : reg_bits
            D_FF_en dff_en_i (.q(q[i]), .d(d[i]), .clk(clk), .reset(reset), .enable(enable));
        end
    endgenerate
endmodule
