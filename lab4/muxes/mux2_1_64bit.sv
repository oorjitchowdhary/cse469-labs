module mux2_1_64bit (
    output logic [63:0] out,
    input logic [63:0] i0,
    input logic [63:0] i1,
    input logic sel
);
    genvar j;
    generate
        for (j = 0; j < 64; j = j + 1) begin : mux_bit
            mux2_1 mux_inst (.out(out[j]), .i0(i0[j]), .i1(i1[j]), .sel(sel));
        end
    endgenerate
endmodule
