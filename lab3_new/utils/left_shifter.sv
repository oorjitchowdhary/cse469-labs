`timescale 1ps/1ps

module left_shifter_2bits (
    input  logic [63:0] in,
    output logic [63:0] out
);
    // force first 2 bits to zero
    and #50 zero0 (out[0], 1'b0, in[0]);
    and #50 zero1 (out[1], 1'b0, in[1]);

    // shift by 2 places
    genvar i;
    generate
        for (i = 0; i < 62; i = i + 1) begin: shifter
            and #50 shift_bit (out[i+2], in[i], 1'b1);
        end
    endgenerate
endmodule
