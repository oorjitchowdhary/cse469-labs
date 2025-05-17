module mux4_1_64bit (
    input  logic [63:0] i0,
    input  logic [63:0] i1,
    input  logic [63:0] i2,
    input  logic [63:0] i3,
    input  logic [1:0]  sel,    // combined 2-bit selector
    output logic [63:0] out
);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : bit_mux
            mux4_1 bitmux (
                .i0(i0[i]),
                .i1(i1[i]),
                .i2(i2[i]),
                .i3(i3[i]),
                .sel0(sel[0]),   // LSB
                .sel1(sel[1]),   // MSB
                .out(out[i])
            );
        end
    endgenerate
endmodule
