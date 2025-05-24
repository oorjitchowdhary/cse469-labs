`timescale 1ps/1ps

module id_ex_pipeline_reg (
    input  logic clk,
    input  logic reset,
    input  logic enable,

    // data I/O
    input  logic [63:0] reg1_in,
    input  logic [63:0] reg2_in,
    input  logic [63:0] imm_in,
    input  logic [4:0]  rd_in,
    input  logic [63:0] pc_plus4_in,
    output logic [63:0] reg1_out,
    output logic [63:0] reg2_out,
    output logic [63:0] imm_out,
    output logic [4:0]  rd_out,
    output logic [63:0] pc_plus4_out,

    // EX stage control signals I/O
    input  logic [2:0] ex_alu_op_in,
    input  logic       ex_alu_src_in,
    input  logic       ex_flag_write_in,
    input  logic       ex_is_cbz_in,
    input  logic       ex_is_blt_in,
    output logic [2:0] ex_alu_op_out,
    output logic       ex_alu_src_out,
    output logic       ex_flag_write_out,
    output logic       ex_is_cbz_out,
    output logic       ex_is_blt_out,

    // MEM stage control signals I/O
    input  logic       mem_mem_read_in,
    input  logic       mem_mem_write_in,
    input  logic       mem_take_branch_in,
    input  logic       mem_uncond_branch_in,
    input  logic       mem_reg_branch_in,
    output logic       mem_mem_read_out,
    output logic       mem_mem_write_out,
    output logic       mem_take_branch_out,
    output logic       mem_uncond_branch_out,
    output logic       mem_reg_branch_out,

    // WB stage control signals I/O
    input  logic       wb_reg_write_in,
    input  logic       wb_mem_to_reg_in,
    input  logic       wb_link_write_in,
    output logic       wb_reg_write_out,
    output logic       wb_mem_to_reg_out,
    output logic       wb_link_write_out
);

    // data registers
    register_64bit reg1      (.q(reg1_out), .d(reg1_in),      .clk(clk), .reset(reset), .enable(enable));
    register_64bit reg2      (.q(reg2_out), .d(reg2_in),      .clk(clk), .reset(reset), .enable(enable));
    register_64bit imm       (.q(imm_out),  .d(imm_in),       .clk(clk), .reset(reset), .enable(enable));
    register_5bit  rd        (.q(rd_out),   .d(rd_in),        .clk(clk), .reset(reset), .enable(enable));
    register_64bit pc_plus4  (.q(pc_plus4_out), .d(pc_plus4_in), .clk(clk), .reset(reset), .enable(enable));

    // EX stage control signal registers
    register_3bit ex_alu_op    (.q(ex_alu_op_out),    .d(ex_alu_op_in),    .clk(clk), .reset(reset), .enable(enable));
    register_1bit ex_alu_src   (.q(ex_alu_src_out),   .d(ex_alu_src_in),   .clk(clk), .reset(reset), .enable(enable));
    register_1bit ex_flag_write(.q(ex_flag_write_out),.d(ex_flag_write_in),.clk(clk), .reset(reset), .enable(enable));
    register_1bit ex_is_blt (.q(ex_is_blt_out), .d(ex_is_blt_in), .clk(clk), .reset(reset), .enable(enable));
    register_1bit ex_is_cbz (.q(ex_is_cbz_out), .d(ex_is_cbz_in), .clk(clk), .reset(reset), .enable(enable));

    // MEM stage control signal registers
    register_1bit mem_mem_read     (.q(mem_mem_read_out),     .d(mem_mem_read_in),     .clk(clk), .reset(reset), .enable(enable));
    register_1bit mem_mem_write    (.q(mem_mem_write_out),    .d(mem_mem_write_in),    .clk(clk), .reset(reset), .enable(enable));
    register_1bit mem_take_branch  (.q(mem_take_branch_out),  .d(mem_take_branch_in),  .clk(clk), .reset(reset), .enable(enable));
    register_1bit mem_uncond_branch(.q(mem_uncond_branch_out),.d(mem_uncond_branch_in),.clk(clk), .reset(reset), .enable(enable));
    register_1bit mem_reg_branch   (.q(mem_reg_branch_out),   .d(mem_reg_branch_in),   .clk(clk), .reset(reset), .enable(enable));

    // WB stage control signal registers
    register_1bit wb_reg_write   (.q(wb_reg_write_out),   .d(wb_reg_write_in),   .clk(clk), .reset(reset), .enable(enable));
    register_1bit wb_mem_to_reg  (.q(wb_mem_to_reg_out),  .d(wb_mem_to_reg_in),  .clk(clk), .reset(reset), .enable(enable));
    register_1bit wb_link_write  (.q(wb_link_write_out),  .d(wb_link_write_in),  .clk(clk), .reset(reset), .enable(enable));

endmodule
