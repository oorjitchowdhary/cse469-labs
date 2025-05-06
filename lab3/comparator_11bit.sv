module comparator_11bit (
    input  logic [10:0] a,
    input  logic [10:0] b,
    output logic        out
);

    logic [10:0] xnor_bits;

    genvar i;
    generate
        for (i = 0; i < 11; i++) begin : xnor_loop
            xnor (xnor_bits[i], a[i], b[i]);
        end
    endgenerate

    and and_all(out, xnor_bits[0], xnor_bits[1], xnor_bits[2], xnor_bits[3], xnor_bits[4],
                      xnor_bits[5], xnor_bits[6], xnor_bits[7], xnor_bits[8], xnor_bits[9], xnor_bits[10]);

endmodule
