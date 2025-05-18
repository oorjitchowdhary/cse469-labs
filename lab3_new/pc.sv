// 64 bit program counter

`timescale 1ps/1ps

module pc (
    input logic clk,
    input logic reset,
    input logic enable,
    input logic [63:0] reg_data, // for BR
    input logic [63:0] se_shifted_imm, // sign extended, left shifted immediate
    input logic [1:0] pc_src, // 00: pc+4, 01: imm, 10: reg, 11: no-op
    output logic [63:0] pc
);
    logic [63:0] pc_plus_4, pc_plus_imm;
    logic [63:0] next_pc;

    // sequential: pc + 4
    adder_64bit pc_seq_increment (.a(pc), .b(64'd4), .cin(1'b0), .sum(pc_plus_4), .cout(), .overflow());

    // offset: pc + branching immediate
    adder_64bit pc_imm_increment (.a(pc), .b(se_shifted_imm), .cin(1'b0), .sum(pc_plus_imm), .cout(), .overflow());

    // next pc selection
    mux4_1_64bit pc_mux (
        .i0(pc_plus_4), // 00: sequential
        .i1(pc_plus_imm), // 01: offset
        .i2(reg_data), // 10: register
        .i3(pc), // 11: reuse for no-op
        .sel(pc_src),
        .out(next_pc)
    );

    // PC DFFs
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : pc_ff
            D_FF_en dff_en_i (.clk(clk), .reset(reset), .enable(enable), .d(next_pc[i]), .q(pc[i]));
        end
    endgenerate
endmodule
