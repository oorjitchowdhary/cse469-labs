`timescale 1ps/1ps

module cpu (
	input logic clk,
	input logic reset
);
    // program counter & instruction memory
	logic [31:0] instruction;
    program_counter pc_inst (
        .clk(clk), .reset(reset),
        .reg_data(br_reg_data), .se_shifted_imm(br_offset),
        .pc_src(pc_src), .pc(curr_pc)
    );

    instructmem imem (.address(curr_pc), .instruction(instruction), .clk(clk));

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
    control_unit cu_inst (
        .instruction(instruction),
        .mem_read(mem_read), .mem_write(mem_write), .reg_write(reg_write),
        .mem_to_reg(mem_to_reg), .reg2loc(reg2loc), .flag_write(flag_write),
        .alu_src(alu_src), .alu_op(alu_op), .take_branch(take_branch), .reg_branch(reg_branch)
    );

    // program counter
    // 3 ways: PC + 4, PC + offset, PC = Reg[Rd]; use 4:1 pc_src mux
    // 00: pc = pc + 4 (ADDI, ADDS, LDUR, STUR, SUBS)
    // 01: pc = pc + SE(imm) << 2 (B, BL, CBZ, B.LT)
    // 10: pc = Reg[Rd] (BR)

    // pc_src derived from take_branch, reg_branch, and branch_condition_met (using ALU flags)

endmodule
