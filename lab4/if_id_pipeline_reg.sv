`timescale 1ps/1ps

module if_id_pipeline_reg (
    input logic clk,
    input logic reset,
    input logic enable,
    input logic valid_in,
    input logic [31:0] instr_in,
    input logic [63:0] pc_plus4_in,
    output logic [31:0] instr_out,
    output logic [63:0] pc_plus4_out,
    output logic valid_out
);

    register_1bit valid_reg (.q(valid_out), .d(valid_in), .clk(clk), .reset(reset), .enable(enable));

    // instruction register
    register_32bit ir_reg (.q(instr_out), .d(instr_in), .clk(clk), .reset(reset), .enable(enable));

    // pc+4 register
    register_64bit pc_plus4_reg (.q(pc_plus4_out), .d(pc_plus4_in), .clk(clk), .reset(reset), .enable(enable));
endmodule
