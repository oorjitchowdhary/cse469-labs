// immediate generator to sign extend to 64 bits

// helper 1-bit buffer
module buf1 (
    input logic in,
    output logic out
);
    assign out = in;
endmodule


module immediate_gen (
    input logic [31:0] instruction,
    input logic is_d_type, // 1 = D-type, 0 = I-type
    output logic [63:0] imm_out
);

    // 12-bit immediate for I-type = ALU_immediate [21:10]
    logic [11:0] imm_I;
    logic sign_I;
    buf1 buf_sign_I (.in(instruction[21]), .out(sign_I));
    genvar i;
    generate
        for (i = 10; i < 22; i = i + 1) begin : I_in
            buf1 buf1_in_immI (.in(instruction[i]), .out(imm_I[i - 10]));
        end
    endgenerate

    // 9-bit immediate for D-type = DT_address [20:12]
    logic [8:0] imm_D;
    logic sign_D;
    buf1 buf_sign_D (.in(instruction[20]), .out(sign_D));
    generate
        for (i = 12; i < 21; i = i + 1) begin : D_in
            buf1 buf1_in_immD (.in(instruction[i]), .out(imm_D[i - 12]));
        end
    endgenerate

    // extended immediate for I-type
    logic [63:0] imm_I_ext;
    generate
        for (i = 0; i < 12; i = i + 1) begin : I_lower
            buf1 buf1_li (.in(imm_I[i]), .out(imm_I_ext[i]));
        end
        for (i = 12; i < 64; i = i + 1) begin : I_upper
            buf1 buf1_ui (.in(sign_I), .out(imm_I_ext[i]));
        end
    endgenerate

    // extended immediate for D-type
    logic [63:0] imm_D_ext;
    generate
        for (i = 0; i < 9; i = i + 1) begin : D_lower
            buf1 buf1_dli (.in(imm_D[i]), .out(imm_D_ext[i]));
        end
        for (i = 9; i < 64; i = i + 1) begin : D_upper
            buf1 buf1_dui (.in(sign_D), .out(imm_D_ext[i]));
        end
    endgenerate

    // mux to decide output
    generate
        for (i = 0; i < 64; i = i + 1) begin : mux_out
            mux2_1 mux_i (.out(imm_out[i]), .i0(imm_I_ext[i]), .i1(imm_D_ext[i]), .sel(is_d_type));
        end
    endgenerate
endmodule
