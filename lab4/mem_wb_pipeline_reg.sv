`timescale 1ps/1ps

module mem_wb_pipeline_reg (
    input logic clk,
    input logic reset,
    input logic enable,

    // data I/O
    input  logic [63:0] alu_result_in,
    input  logic [63:0] mem_data_in,
    input  logic [63:0] pc_plus4_in,
    input  logic [4:0]  rd_in,
    output logic [63:0] alu_result_out,
    output logic [63:0] mem_data_out,
    output logic [4:0]  rd_out,
    output logic [63:0] pc_plus4_out,

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
    register_64bit mem_data   (.q(mem_data_out),   .d(mem_data_in),   .clk(clk), .reset(reset), .enable(enable));
    register_5bit  rd         (.q(rd_out),         .d(rd_in),         .clk(clk), .reset(reset), .enable(enable));
    register_64bit pc_plus4  (.q(pc_plus4_out), .d(pc_plus4_in), .clk(clk), .reset(reset), .enable(enable));

    // WB stage control signal registers
    D_FF_en reg_write   (.q(wb_reg_write_out),  .d(wb_reg_write_in),  .clk(clk), .reset(reset), .enable(enable));
    D_FF_en mem_to_reg  (.q(wb_mem_to_reg_out), .d(wb_mem_to_reg_in), .clk(clk), .reset(reset), .enable(enable));
    D_FF_en link_write  (.q(wb_link_write_out), .d(wb_link_write_in), .clk(clk), .reset(reset), .enable(enable));

endmodule
