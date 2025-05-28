`timescale 1ps/1ps

module ex_mem_pipeline_reg (
    input logic clk,
    input logic reset,
    input logic enable,

    // data I/O
    input  logic [63:0] alu_result_in,
    input  logic [63:0] reg2_data_in,
    input  logic [4:0]  rd_in,
    input  logic        branch_condition_met_in,
    input  logic [63:0] pc_plus4_in,
    output logic [63:0] alu_result_out,
    output logic [63:0] reg2_data_out,
    output logic [4:0]  rd_out,
    output logic        branch_condition_met_out,
    output logic [63:0] pc_plus4_out,

    // MEM stage control signals I/O
    input  logic mem_mem_read_in,
    input  logic mem_mem_write_in,
    input  logic mem_take_branch_in,
    input  logic mem_uncond_branch_in,
    input  logic mem_reg_branch_in,
    output logic mem_mem_read_out,
    output logic mem_mem_write_out,
    output logic mem_take_branch_out,
    output logic mem_uncond_branch_out,
    output logic mem_reg_branch_out,

    // WB stage control signals I/O
    input  logic wb_reg_write_in,
    input  logic wb_mem_to_reg_in,
    input  logic wb_link_write_in,
    output logic wb_reg_write_out,
    output logic wb_mem_to_reg_out,
    output logic wb_link_write_out
);

    // data registers
    register_64bit alu_result (.q(alu_result_out), .d(alu_result_in), .clk(clk), .reset(reset), .enable(enable));
    register_64bit reg2_data  (.q(reg2_data_out),  .d(reg2_data_in),  .clk(clk), .reset(reset), .enable(enable));
    register_5bit  rd         (.q(rd_out),         .d(rd_in),         .clk(clk), .reset(reset), .enable(enable));
    D_FF_en  branch_cond(.q(branch_condition_met_out), .d(branch_condition_met_in), .clk(clk), .reset(reset), .enable(enable));
    register_64bit pc_plus4  (.q(pc_plus4_out), .d(pc_plus4_in), .clk(clk), .reset(reset), .enable(enable));

    // MEM stage control signal registers
    D_FF_en mem_read     (.q(mem_mem_read_out),     .d(mem_mem_read_in),     .clk(clk), .reset(reset), .enable(enable));
    D_FF_en mem_write    (.q(mem_mem_write_out),    .d(mem_mem_write_in),    .clk(clk), .reset(reset), .enable(enable));
    D_FF_en take_branch  (.q(mem_take_branch_out),  .d(mem_take_branch_in),  .clk(clk), .reset(reset), .enable(enable));
    D_FF_en uncond_branch(.q(mem_uncond_branch_out),.d(mem_uncond_branch_in),.clk(clk), .reset(reset), .enable(enable));
    D_FF_en reg_branch   (.q(mem_reg_branch_out),   .d(mem_reg_branch_in),   .clk(clk), .reset(reset), .enable(enable));

    // WB stage control signal registers
    D_FF_en reg_write   (.q(wb_reg_write_out),   .d(wb_reg_write_in),   .clk(clk), .reset(reset), .enable(enable));
    D_FF_en mem_to_reg  (.q(wb_mem_to_reg_out),  .d(wb_mem_to_reg_in),  .clk(clk), .reset(reset), .enable(enable));
    D_FF_en link_write  (.q(wb_link_write_out),  .d(wb_link_write_in),  .clk(clk), .reset(reset), .enable(enable));

endmodule
