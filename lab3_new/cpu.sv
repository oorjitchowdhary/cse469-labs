`timescale 1ps/1ps

module cpu (
	input logic clk,
	input logic reset
);
    // instruction fetch
    logic [63:0] curr_pc, br_reg_data, br_uncond_offset, br_cond_offset;
    logic [1:0] pc_src;

    // pc_src 00: pc+4, 01: uncond branch, 10: cond branch, 11: reg
    program_counter pc_inst (
        .clk(clk), .reset(reset),
        .reg_data(br_reg_data), // br_reg_data = Reg[Rd]
        .se_shifted_brAddr(br_uncond_offset), // br_uncond_offset = SE(brAddr26) << 2
        .se_shifted_condAddr(br_cond_offset), // br_cond_offset = SE(condAddr19) << 2
        .pc_src(pc_src), .pc(curr_pc)
    );

	logic [31:0] instruction;
    instructmem imem (.address(curr_pc), .instruction(instruction), .clk(clk));

    // instruction decode
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

    // handling for pc
    logic se_brAddr, se_condAddr;
    sign_extender_btype se_b_inst (.in(brAddr26), .out(se_brAddr));
    sign_extender_cbtype se_cb_inst (.in(condAddr19), .out(se_condAddr));
    left_shifter_2bits ls_b_inst (.in(se_brAddr), .out(br_uncond_offset));
    left_shifter_2bits ls_cb_inst (.in(se_condAddr), .out(br_cond_offset));

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
    logic take_branch, reg_branch, uncond_branch, link_write;
    control_unit cu_inst (
        .instruction(instruction),
        .mem_read(mem_read), .mem_write(mem_write), .reg_write(reg_write),
        .mem_to_reg(mem_to_reg), .reg2loc(reg2loc), .flag_write(flag_write),
        .alu_src(alu_src), .alu_op(alu_op), .take_branch(take_branch),
        .reg_branch(reg_branch), .uncond_branch(uncond_branch), .link_write(link_write)
    );

    // deriving pc_src from control signals
    // pc_src[1] = reg_branch
    // pc_src[0] = take_branch & ~reg_branch & ~uncond_branch
    assign pc_src[1] = reg_branch;
    logic not_reg_branch, not_uncond_branch;
    not #50 not_rb (not_reg_branch, reg_branch);
    not #50 not_ub (not_uncond_branch, uncond_branch);
    and #50 and_pcsrc (pc_src[0], take_branch, not_reg_branch, not_uncond_branch);

    // register file
    regfile rf_inst (
        .ReadData1(),
        .ReadData2(),
        .WriteData(),
        .ReadRegister1(),
        .ReadRegister2(),
        .WriteRegister(),
        .RegWrite(),
        .clk(clk)
    );

    // ALU
    alu alu_inst (
        .A(), .B(), .result(),
        .cntrl(),
        .negative(), .zero(),
        .carry_out(), .overflow()
    );

    // data memory
    datamem dmem (

    );

endmodule
