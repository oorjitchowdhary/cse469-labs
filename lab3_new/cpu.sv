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
    logic [63:0] se_brAddr, se_condAddr;
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
    logic mem_to_reg, reg2loc, alu_src, imm_is_dtype;
    logic take_branch, reg_branch, uncond_branch, link_write;
    control_unit cu_inst (
        .instruction(instruction), .imm_is_dtype(imm_is_dtype),
        .mem_read(mem_read), .mem_write(mem_write), .reg_write(reg_write),
        .mem_to_reg(mem_to_reg), .reg2loc(reg2loc), .flag_write(flag_write),
        .alu_src(alu_src), .alu_op(alu_op), .take_branch(take_branch),
        .reg_branch(reg_branch), .uncond_branch(uncond_branch), .link_write(link_write)
    );

    // deriving pc_src from control signals
    // pc_src[1] = reg_branch
    // pc_src[0] = take_branch & ~reg_branch & ~uncond_branch & branch_condition_met
    assign pc_src[1] = reg_branch;
    logic not_reg_branch, not_uncond_branch, branch_condition_met;
    not #50 not_rb (not_reg_branch, reg_branch);
    not #50 not_ub (not_uncond_branch, uncond_branch);
    and #50 and_pcsrc (pc_src[0], take_branch, not_reg_branch, not_uncond_branch, branch_condition_met);

    // register file
    logic [4:0] selected_R2;
    mux2_1_5bit r2_mux (.out(selected_R2), .i0(Rd), .i1(Rm), .sel(reg2loc));

    logic [63:0] regs [31:0];
    logic [63:0] reg1_data, reg2_data, reg_write_data;
    regfile rf_inst (
        .reg_out(regs),
        .ReadData1(reg1_data),
        .ReadData2(reg2_data),
        .WriteData(reg_write_data), // selected using mem_to_reg mux
        .ReadRegister1(Rn),
        .ReadRegister2(selected_R2), // Rm vs Rd
        .WriteRegister(Rd),
        .RegWrite(reg_write),
        .clk(clk), .reset(reset)
    );

    // check whether Reg[Rd] is zero for CBZ
    logic cbz_met;
    zero_64bits cbz_zero (.in(reg1_data), .zero(cbz_met));

    // ALU
    // immediate = dAddr9 or imm12
    logic [63:0] se_immediate, se_dAddr, ze_imm12;
    zero_extender_itype ze_i_inst (.in(imm12), .out(ze_imm12));
    sign_extender_dtype se_d_inst (.in(dAddr9), .out(se_dAddr));
    mux2_1_64bit imm_mux (.out(se_immediate), .i0(ze_imm12), .i1(se_dAddr), .sel(imm_is_dtype));

    // input_b = reg2_data or immediate
    logic [63:0] input_b, alu_result;
    mux2_1_64bit alu_b_mux (.out(input_b), .i0(reg2_data), .i1(se_immediate), .sel(alu_src));

    // flags
    logic alu_negative, alu_zero, alu_carry_out, alu_overflow;
    logic negative_flag, zero_flag, carry_out_flag, overflow_flag;

    alu alu_inst (
        .A(reg1_data), .B(input_b), .result(alu_result),
        .cntrl(alu_op),
        .negative(alu_negative), .zero(alu_zero),
        .carry_out(alu_carry_out), .overflow(alu_overflow)
    );

    // set flags based on flag_write
    and #50 n_flag (negative_flag, flag_write, alu_negative);
    and #50 z_flag (zero_flag, flag_write, alu_zero);
    and #50 c_flag (carry_out_flag, flag_write, alu_carry_out);
    and #50 v_flag (overflow_flag, flag_write, alu_overflow);

    // check whether B.LT condition is met
    logic blt_met;
    xor #50 blt_cond_xor (blt_met, negative_flag, overflow_flag);

    // final branch_condition_met
    or #50 cond_branch_or (branch_condition_met, blt_met, cbz_met);

    // data memory
    logic [63:0] mem_read_data;
    datamem dmem (
        .address(alu_result),
        .write_enable(mem_write),
        .read_enable(mem_read),
        .write_data(reg2_data),
        .read_data(mem_read_data),
        .xfer_size(4'b1000),
        .clk(clk)
    );

    // reg write back mux
    mux2_1_64bit reg_wb_mux (.out(reg_write_data), .i0(alu_result), .i1(mem_read_data), .sel(mem_to_reg));

endmodule

// top level CPU testbench
module cpustim();
    logic clk, reset;

    // Instantiate the CPU
    cpu DUT (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation: 4000ps period (2000ps half-cycle)
    initial begin
        clk = 0;
        forever #2000 clk = ~clk;
    end

    // Reset pulse and simulation duration
    initial begin
        reset = 1;
        #4000;
        reset = 0;

        // Run for ~20 instruction cycles (adjust as needed)
        repeat (20) @(posedge clk);

        $stop;
    end
endmodule
