`timescale 1ps/1ps

module comparator_5bit (
    input  logic [4:0] a,
    input  logic [4:0] b,
    output logic       equal
);
    logic [4:0] xnor_bits;

    genvar i;
    generate
        for (i = 0; i < 5; i++) begin: xnor_loop
            xnor #50 (xnor_bits[i], a[i], b[i]);
        end
    endgenerate

    and #50 and_all(equal, xnor_bits[0], xnor_bits[1], xnor_bits[2], xnor_bits[3], xnor_bits[4]);
endmodule
