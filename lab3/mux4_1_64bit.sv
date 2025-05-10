module mux4_1_64bit (
    input  logic [63:0] in0,
    input  logic [63:0] in1,
    input  logic [63:0] in2,
    input  logic [63:0] in3,
    input  logic [1:0]  sel,    // combined 2-bit selector
    output logic [63:0] out
);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : bit_mux
            mux4_1 bitmux (
                .i0(in0[i]),
                .i1(in1[i]),
                .i2(in2[i]),
                .i3(in3[i]),
                .sel0(sel[0]),   // LSB
                .sel1(sel[1]),   // MSB
                .out(out[i])
            );
        end
    endgenerate
endmodule
