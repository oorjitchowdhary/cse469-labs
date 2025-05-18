`timescale 1ps/1ps

module cpu (
	input logic clk,
	input logic reset
);
	logic [31:0] instruction;

	logic [10:0] opcode;
	assign opcode = instruction[31:21];

	logic [4:0] Rd, Rn, Rm;
    assign Rd = instruction[4:0];
	assign Rn = instruction[9:5];
	assign Rm = instruction[20:16];

	logic [25:0] brAddr26;
	logic [18:0] condAddr19;
	assign brAddr26 = instruction[25:0];
	assign condAddr19 = instruction[23:5];

	logic [11:0] imm12;
	logic [8:0] dAddr9;
	logic [5:0] shamt;
	assign imm12 = instruction[21:10];
	assign dAddr9 = instruction[20:12];
	assign shamt = instruction[15:10];

    // control unit
    logic mem_read, mem_write, reg_write, flag_write;
    logic [2:0] alu_op;
    logic mem_to_reg, reg2loc, alu_src;
    logic take_branch, reg_branch;

    // program counter
    // 3 ways: PC + 4, PC + offset, PC = Reg[Rd]; use 4:1 pc_src mux
    // 00: pc = pc + 4 (ADDI, ADDS, LDUR, STUR, SUBS)
    // 01: pc = SE(imm) << 2 (B, BL, CBZ, B.LT)
    // 10: pc = Reg[Rd] (BR)

    // pc_src derived from take_branch, reg_branch, and branch_condition_met (using ALU flags)

endmodule
