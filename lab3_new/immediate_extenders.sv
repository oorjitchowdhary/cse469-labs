// sign/zero extender modules for different instruction types

// helper 1-bit buffer
module buf1 (
    input logic in,
    output logic out
);
    assign out = in;
endmodule

// I-type zero extender - 12 bits to 64 bits
module zero_extender_itype (
    input logic [11:0] in,
    output logic [63:0] out
);
    genvar i;
    generate
        for (i = 0; i < 12; i = i + 1) begin : copy_bits
            buf1 b_copy (.in(in[i]), .out(out[i]));
        end
        for (i = 12; i < 64; i = i + 1) begin : extend_sign
            buf1 b_sign (.in(1'b0), .out(out[i]));
        end
    endgenerate
endmodule

// D-type sign extender - 9 bits to 64 bits
module sign_extender_dtype (
    input logic [8:0] in,
    output logic [63:0] out
);
    genvar i;
    generate
        for (i = 0; i < 9; i = i + 1) begin : copy_bits
            buf1 b_copy (.in(in[i]), .out(out[i]));
        end
        for (i = 9; i < 64; i = i + 1) begin : extend_sign
            buf1 b_sign (.in(in[8]), .out(out[i]));
        end
    endgenerate
endmodule

// B-type sign extender - 26 bits to 64 bits
module sign_extender_btype (
    input logic [25:0] in,
    output logic [63:0] out
);
    genvar i;
    generate
        for (i = 0; i < 26; i = i + 1) begin : copy_bits
            buf1 b_copy (.in(shift_in[i]), .out(out[i]));
        end
        for (i = 26; i < 64; i = i + 1) begin : extend_sign
            buf1 b_sign (.in(shift_in[25]), .out(out[i]));
        end
    endgenerate
endmodule

// CB-type sign extender - 19 bits to 64 bits
module sign_extender_cbtype (
    input logic [18:0] in,
    output logic [63:0] out
);
    genvar i;
    generate
        for (i = 0; i < 19; i = i + 1) begin : copy_bits
            buf1 b_copy (.in(shift_in[i]), .out(out[i]));
        end
        for (i = 19; i < 64; i = i + 1) begin : extend_sign
            buf1 b_sign (.in(shift_in[18]), .out(out[i]));
        end
    endgenerate
endmodule
