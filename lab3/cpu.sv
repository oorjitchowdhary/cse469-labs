// top level CPU
`timescale 1ns/10ps

module cpu (
	input logic clk,
	input logic reset
);
	
	logic [4:0] Rd, Rn, Rm;
	logic [25:0] brAddr26;
	logic [18:0] condAddr19;
	logic [8:0] dAddr9;
	logic [5:0] shamt;
	logic [11:0] imm12;
	logic [10:0] opcode;
	logic [31:0] instruction;
	assign opcode = instruction[31:21];
	assign Rd = instruction[4:0];
	assign Rn = instruction[9:5];
	assign Rm = instruction[20:16];
	assign shamt = instruction[15:10];
	assign imm12 = instruction[21:10];
	assign dAddr9 = instruction[20:12];
	assign brAddr26 = instruction[25:0];
	assign condAddr19 = instruction[23:5];
	
	// control unit
	logic reg_write, alu_src, mem_read, mem_write, mem_to_reg;
	logic flag_write, take_branch, uncond_branch, reg_branch, reg2loc;
	logic [1:0] itype; // 00 = I, 01 = D/R, 10 = B, 11 = CB
	logic [2:0] alu_op;

	control_unit ctrl (
		.instruction(instruction),
		.itype(itype),
		.reg_write(reg_write),
		.alu_src(alu_src),
		.alu_op(alu_op),
		.mem_read(mem_read),
		.mem_write(mem_write),
		.mem_to_reg(mem_to_reg),
		.flag_write(flag_write),
		.take_branch(take_branch),
		.uncond_branch(uncond_branch),
		.reg_branch(reg_branch),
		.reg2loc(reg2loc)
	);
	
	// flags
	logic alu_negative, alu_zero, alu_carry, alu_overflow;

	logic negative_d, negative_q;
	logic zero_d, zero_q;
	logic carry_d, carry_q;
	logic overflow_d, overflow_q;

	mux2_1 mux_n (.out(negative_d), .i0(negative_q), .i1(alu_negative), .sel(flag_write));
	mux2_1 mux_z (.out(zero_d),     .i0(zero_q),     .i1(alu_zero),     .sel(flag_write));
	mux2_1 mux_c (.out(carry_d),    .i0(carry_q),    .i1(alu_carry),    .sel(flag_write));
	mux2_1 mux_v (.out(overflow_d), .i0(overflow_q), .i1(alu_overflow), .sel(flag_write));

	D_FF dff_n (.q(negative_q), .d(negative_d), .reset(reset), .clk(clk));
	D_FF dff_z (.q(zero_q),     .d(zero_d),     .reset(reset), .clk(clk));
	D_FF dff_c (.q(carry_q),    .d(carry_d),    .reset(reset), .clk(clk));
	D_FF dff_v (.q(overflow_q), .d(overflow_d), .reset(reset), .clk(clk));
	
	// immediate generators
	logic [63:0] imm_ext_i, imm_ext_d, imm_ext_b, imm_ext_cb;
	zero_extender_itype ext_i (.in(imm12), .out(imm_ext_i));
	sign_extender_dtype ext_d (.in(dAddr9), .out(imm_ext_d));
	sign_extender_btype ext_b (.in(brAddr26), .out(imm_ext_b));
	sign_extender_cbtype ext_cb (.in(condAddr19), .out(imm_ext_cb));
	
	// program counter
	logic [63:0] curr_pc, next_pc, pc_plus_4, branch_target;
	logic [63:0] next_pc_mux_out;

	pc pc_inst (.clk(clk), .reset(reset), .curr_pc(curr_pc), .next_pc(next_pc_mux_out));

	// sequential: PC + 4
	adder_64bit seq_adder (.a(curr_pc), .b(64'd4), .cin(1'b0), .sum(pc_plus_4), .cout());

	// branch target logic
	logic [63:0] selected_branch_offset;
	mux2_1_64bit branch_offset_mux (.out(selected_branch_offset), .i0(imm_ext_cb), .i1(imm_ext_b), .sel(uncond_branch));
	adder_64bit branch_adder (.a(curr_pc), .b(selected_branch_offset), .cin(1'b0), .sum(branch_target), .cout());

	// next PC mux
	mux2_1_64bit next_pc_mux (.out(next_pc_mux_out), .i0(pc_plus_4), .i1(branch_target), .sel(take_branch));

	// instruction memory
	instructmem imem (.address(curr_pc), .instruction(instruction), .clk(clk));
	
	// register file
	logic [4:0] R_mux;
	mux2_1_5bit reg_mux (.out(R_mux), .i0(Rm), .i1(Rd), .sel(reg2loc));
	
	logic [63:0] Da, Db, WriteData;
	regfile regs (
		.ReadRegister1(Rn),
		.ReadRegister2(R_mux),
		.WriteRegister(Rd),
		.ReadData1(Da),
		.ReadData2(Db),
		.WriteData(WriteData),
		.RegWrite(reg_write),
		.clk(clk)
	);
	
	// immediate mux: dArr9 vs imm12
	logic [63:0] imm_selected;
	mux2_1_64bit imm_sel_mux (.out(imm_selected), .i0(imm_ext_i), .i1(imm_ext_d), .sel(itype[0]));
	
	// ALU
	// input_b = immediate or register
	logic [63:0] input_b, alu_result;
	mux2_1_64bit alu_src_mux (.out(input_b), .i0(Db), .i1(imm_selected), .sel(alu_src));
	
	alu alu_inst (
		.A(Da),
		.B(input_b),
		.cntrl(alu_op),
		.result(alu_result),
		.negative(alu_negative),
		.zero(alu_zero),
		.overflow(alu_overflow),
		.carry_out(alu_carry)
	);
	
	// data memory
	logic [63:0] mem_read_data;
	datamem dmem (
		.address(alu_result),
		.write_enable(mem_write),
		.read_enable(mem_read),
		.write_data(Db),
		.clk(clk),
		.xfer_size(4'b1000),
		.read_data(mem_read_data)
	);
	
	// write back mux
	mux2_1_64bit write_mux (.out(WriteData), .i0(alu_result), .i1(mem_read_data), .sel(mem_to_reg));
endmodule

// CPU testbench
module cpu_tb;

    logic clk, reset;
    cpu DUT (.clk(clk), .reset(reset));

    initial begin
        clk = 0;
        forever #50 clk = ~clk;  // 100 ns period
    end

    initial begin
        reset = 1;
        #100;
        reset = 0;

        // Run for enough cycles (adjust if needed)
        repeat (200) @(posedge clk);
        $stop;
    end

endmodule
