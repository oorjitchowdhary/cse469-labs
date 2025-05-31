`timescale 1ps/1ps

module cpu (
	input logic clk,
	input logic reset
);
    // IF: Instruction Fetch
    logic [63:0] curr_pc, br_reg_data, br_uncond_offset, br_cond_offset;
    logic [1:0] pc_src;

    // stall signal from hazard unit (in ID)
    logic stall;

    // pc_src 00: pc+4, 01: uncond branch, 10: cond branch, 11: reg
    program_counter pc_inst (
        .clk(clk), .reset(reset), .enable(~stall),
        .reg_data(br_reg_data), // br_reg_data = Reg[Rd]
        .se_shifted_brAddr(br_uncond_offset), // br_uncond_offset = SE(brAddr26) << 2
        .se_shifted_condAddr(br_cond_offset), // br_cond_offset = SE(condAddr19) << 2
        .pc_src(pc_src), .pc(curr_pc)
    );

    // calculating pc+4 for WB stage
    logic [63:0] pc_plus4;
    adder_64bit pc_inc4 (.a(curr_pc), .b(64'd4), .cin(1'b0), .sum(pc_plus4), .cout(), .overflow());

    // using curr_pc address to fetch instruction
	logic [31:0] instruction;
    instructmem imem (.address(curr_pc), .instruction(instruction), .clk(clk));

    // IF/ID pipeline register
    logic [31:0] if_id_instruction;
    logic [63:0] if_id_pc_plus4;

    if_id_pipeline_reg if_id_reg (
        .clk(clk), .reset(reset), .enable(~stall), // TODO: stalling
        .instr_in(instruction), .instr_out(if_id_instruction),
        .pc_plus4_in(pc_plus4), .pc_plus4_out(if_id_pc_plus4)
    );

    // ID: Instruction Decode
	logic [10:0] opcode;
	assign opcode = if_id_instruction[31:21];

	logic [4:0] Rd, Rn, Rm;
    assign Rd = if_id_instruction[4:0];
	assign Rn = if_id_instruction[9:5];
	assign Rm = if_id_instruction[20:16];

	logic [25:0] brAddr26;
	logic [18:0] condAddr19;
	assign brAddr26 = if_id_instruction[25:0];
	assign condAddr19 = if_id_instruction[23:5];

	logic [11:0] imm12;
	logic [8:0] dAddr9;
	logic [5:0] shamt;
	assign imm12 = if_id_instruction[21:10];
	assign dAddr9 = if_id_instruction[20:12];
	assign shamt = if_id_instruction[15:10];

    // control unit
    logic mem_read, mem_write, reg_write, flag_write;
    logic [2:0] alu_op;
    logic mem_to_reg, reg2loc, alu_src, imm_is_dtype, is_cb_type;
    logic take_branch, reg_branch, uncond_branch, link_write;
    logic is_blt, is_cbz;
    control_unit cu_inst (
        .instruction(if_id_instruction), .imm_is_dtype(imm_is_dtype), .is_cb_type(is_cb_type),
        .mem_read(mem_read), .mem_write(mem_write), .reg_write(reg_write),
        .mem_to_reg(mem_to_reg), .reg2loc(reg2loc), .flag_write(flag_write),
        .alu_src(alu_src), .alu_op(alu_op), .take_branch(take_branch),
        .reg_branch(reg_branch), .uncond_branch(uncond_branch), .link_write(link_write),
        .is_blt(is_blt), .is_cbz(is_cbz)
    );

    // register file specifics
    // regfile module is in WB stage
    logic [4:0] selected_R1, selected_R2;
    mux2_1_5bit r1_mux (.out(selected_R1), .i0(Rn), .i1(Rd), .sel(is_cb_type));
    mux2_1_5bit r2_mux (.out(selected_R2), .i0(Rm), .i1(Rd), .sel(reg2loc));
    logic [63:0] regs [31:0];
    logic [63:0] reg1_data, reg2_data, reg_write_data;

    // populating br_reg_data for BR instruction
    mux2_1_64bit br_reg_mux (.out(br_reg_data), .i0(64'd0), .i1(reg2_data), .sel(reg_branch));

    // immediate = dAddr9 or imm12
    logic [63:0] se_immediate, se_dAddr, ze_imm12;
    zero_extender_itype ze_i_inst (.in(imm12), .out(ze_imm12));
    sign_extender_dtype se_d_inst (.in(dAddr9), .out(se_dAddr));
    mux2_1_64bit imm_mux (.out(se_immediate), .i0(ze_imm12), .i1(se_dAddr), .sel(imm_is_dtype));

    // sign extending and left shifting branch target address
    logic [63:0] se_brAddr, se_condAddr;
    sign_extender_btype se_b_inst (.in(brAddr26), .out(se_brAddr));
    sign_extender_cbtype se_cb_inst (.in(condAddr19), .out(se_condAddr));
    left_shifter_2bits ls_b_inst (.in(se_brAddr), .out(br_uncond_offset));
    left_shifter_2bits ls_cb_inst (.in(se_condAddr), .out(br_cond_offset));

    // ID/EX pipeline register
    logic [63:0] id_ex_reg1_data, id_ex_reg2_data, id_ex_imm, id_ex_pc_plus4;
    logic [4:0]  id_ex_rd;
    logic [2:0] id_ex_alu_op;
    logic id_ex_alu_src, id_ex_flag_write, id_ex_mem_read, id_ex_mem_write;
    logic id_ex_take_branch, id_ex_uncond_branch, id_ex_reg_branch;
    logic id_ex_reg_write, id_ex_mem_to_reg, id_ex_link_write;
    logic id_ex_is_cbz, id_ex_is_blt;
    logic [4:0] id_ex_reg1_src, id_ex_reg2_src;

    logic alu_src_stall, flag_write_stall, mem_read_stall, mem_write_stall, take_branch_stall;
    logic uncond_branch_stall, reg_branch_stall, reg_write_stall, mem_to_reg_stall;
    logic link_write_stall, is_cbz_stall, is_blt_stall;
    logic [2:0] alu_op_stall;
    logic [63:0] reg1_stall, reg2_stall, imm_stall, pc_plus4_stall;
    logic [4:0] rd_stall;
    mux2_1        alu_src_mux         (.i0(1'b0),       .i1(alu_src),        .sel(~stall), .out(alu_src_stall));
    mux2_1        flag_write_mux      (.i0(1'b0),       .i1(flag_write),     .sel(~stall), .out(flag_write_stall));
    mux2_1        mem_read_mux        (.i0(1'b0),       .i1(mem_read),       .sel(~stall), .out(mem_read_stall));
    mux2_1        mem_write_mux       (.i0(1'b0),       .i1(mem_write),      .sel(~stall), .out(mem_write_stall));
    mux2_1        take_branch_mux     (.i0(1'b0),       .i1(take_branch),    .sel(~stall), .out(take_branch_stall));
    mux2_1        uncond_branch_mux   (.i0(1'b0),       .i1(uncond_branch),  .sel(~stall), .out(uncond_branch_stall));
    mux2_1        reg_branch_mux      (.i0(1'b0),       .i1(reg_branch),     .sel(~stall), .out(reg_branch_stall));
    mux2_1        reg_write_mux       (.i0(1'b0),       .i1(reg_write),      .sel(~stall), .out(reg_write_stall));
    mux2_1        mem_to_reg_mux      (.i0(1'b0),       .i1(mem_to_reg),     .sel(~stall), .out(mem_to_reg_stall));
    mux2_1        link_write_mux      (.i0(1'b0),       .i1(link_write),     .sel(~stall), .out(link_write_stall));
    mux2_1        is_cbz_mux          (.i0(1'b0),       .i1(is_cbz),         .sel(~stall), .out(is_cbz_stall));
    mux2_1        is_blt_mux          (.i0(1'b0),       .i1(is_blt),         .sel(~stall), .out(is_blt_stall));
    mux2_1_3bit   alu_op_mux          (.i0(3'b000),     .i1(alu_op),         .sel(~stall), .out(alu_op_stall));
    mux2_1_5bit   rd_mux              (.i0(5'd0),       .i1(Rd),             .sel(~stall), .out(rd_stall));
    mux2_1_64bit  reg1_mux            (.i0(64'd0),      .i1(reg1_data),      .sel(~stall), .out(reg1_stall));
    mux2_1_64bit  reg2_mux            (.i0(64'd0),      .i1(reg2_data),      .sel(~stall), .out(reg2_stall));
    mux2_1_64bit  imm_mux_stall       (.i0(64'd0),      .i1(se_immediate),   .sel(~stall), .out(imm_stall));
    mux2_1_64bit  pc_plus4_mux        (.i0(64'd0),      .i1(if_id_pc_plus4), .sel(~stall), .out(pc_plus4_stall));

    id_ex_pipeline_reg id_ex_reg (
        .clk(clk), .reset(reset), .enable(~stall),

        // data
        .selected_r1_in(selected_R1), .selected_r1_out(id_ex_reg1_src),
        .selected_r2_in(selected_R2), .selected_r2_out(id_ex_reg2_src),
        .reg1_in(reg1_stall),       .reg1_out(id_ex_reg1_data),
        .reg2_in(reg2_stall),       .reg2_out(id_ex_reg2_data),
        .imm_in(imm_stall),         .imm_out(id_ex_imm),
        .rd_in(rd_stall),           .rd_out(id_ex_rd),
        .pc_plus4_in(pc_plus4_stall), .pc_plus4_out(id_ex_pc_plus4),

        // EX stage controls
        .ex_alu_op_in(alu_op_stall),        .ex_alu_op_out(id_ex_alu_op),
        .ex_alu_src_in(alu_src_stall),      .ex_alu_src_out(id_ex_alu_src),
        .ex_flag_write_in(flag_write_stall),.ex_flag_write_out(id_ex_flag_write),
        .ex_is_blt_in(is_blt_stall),        .ex_is_blt_out(id_ex_is_blt),
        .ex_is_cbz_in(is_cbz_stall),        .ex_is_cbz_out(id_ex_is_cbz),

        // MEM stage controls
        .mem_mem_read_in(mem_read_stall),        .mem_mem_read_out(id_ex_mem_read),
        .mem_mem_write_in(mem_write_stall),      .mem_mem_write_out(id_ex_mem_write),
        .mem_take_branch_in(take_branch_stall),  .mem_take_branch_out(id_ex_take_branch),
        .mem_uncond_branch_in(uncond_branch_stall), .mem_uncond_branch_out(id_ex_uncond_branch),
        .mem_reg_branch_in(reg_branch_stall),    .mem_reg_branch_out(id_ex_reg_branch),

        // WB stage controls
        .wb_reg_write_in(reg_write_stall),     .wb_reg_write_out(id_ex_reg_write),
        .wb_mem_to_reg_in(mem_to_reg_stall),   .wb_mem_to_reg_out(id_ex_mem_to_reg),
        .wb_link_write_in(link_write_stall),   .wb_link_write_out(id_ex_link_write)
    );

    // EX: Execution
    // input_b = reg2_data or immediate
    logic [63:0] input_b, alu_result;
    logic [63:0] alu_input_a, alu_input_b;

    // flags
    logic alu_negative, alu_zero, alu_carry_out, alu_overflow;
    logic negative_flag, zero_flag, carry_out_flag, overflow_flag;

    alu alu_inst (
        .A(alu_input_a), .B(input_b), .result(alu_result),
        .cntrl(id_ex_alu_op),
        .negative(alu_negative), .zero(alu_zero),
        .carry_out(alu_carry_out), .overflow(alu_overflow)
    );

    // set flags based on flag_write
    D_FF_en n_dff (.q(negative_flag), .d(alu_negative), .clk(clk), .reset(reset), .enable(id_ex_flag_write));
    D_FF_en z_dff (.q(zero_flag), .d(alu_zero), .clk(clk), .reset(reset), .enable(id_ex_flag_write));
    D_FF_en c_dff (.q(carry_out_flag), .d(alu_carry_out), .clk(clk), .reset(reset), .enable(id_ex_flag_write));
    D_FF_en v_dff (.q(overflow_flag), .d(alu_overflow), .clk(clk), .reset(reset), .enable(id_ex_flag_write));

    // check whether Reg[Rd] is zero for CBZ
    logic cbz_cond_met;
    zero_64bits cbz_zero (.in(alu_input_a), .zero(cbz_cond_met));

    // check whether B.LT condition is met
    logic blt_cond_met;
    xor #50 blt_cond_xor (blt_cond_met, negative_flag, overflow_flag);

    // final branch_condition_met
    logic blt_met, cbz_met;
    and #50 (blt_met, id_ex_is_blt, blt_cond_met);
    and #50 (cbz_met, id_ex_is_cbz, cbz_cond_met);
    or #50 cond_branch_or (branch_condition_met, blt_met, cbz_met);

    // EX/MEM pipeline register
    logic [63:0] ex_mem_alu_result, ex_mem_reg2_data, ex_mem_pc_plus4;
    logic [4:0]  ex_mem_rd;
    logic ex_mem_branch_condition_met, ex_mem_mem_read, ex_mem_mem_write;
    logic ex_mem_take_branch, ex_mem_uncond_branch, ex_mem_reg_branch;
    logic ex_mem_reg_write, ex_mem_mem_to_reg, ex_mem_link_write;

    ex_mem_pipeline_reg ex_mem_reg (
        .clk(clk), .reset(reset), .enable(1'b1),

        // data
        .alu_result_in(alu_result), .alu_result_out(ex_mem_alu_result),
        .reg2_data_in(alu_input_b), .reg2_data_out(ex_mem_reg2_data),
        .rd_in(id_ex_rd), .rd_out(ex_mem_rd),
        .branch_condition_met_in(branch_condition_met), .branch_condition_met_out(ex_mem_branch_condition_met),
        .pc_plus4_in(id_ex_pc_plus4), .pc_plus4_out(ex_mem_pc_plus4),

        // MEM stage controls
        .mem_mem_read_in(id_ex_mem_read),.mem_mem_read_out(ex_mem_mem_read),
        .mem_mem_write_in(id_ex_mem_write), .mem_mem_write_out(ex_mem_mem_write),
        .mem_take_branch_in(id_ex_take_branch), .mem_take_branch_out(ex_mem_take_branch),
        .mem_uncond_branch_in(id_ex_uncond_branch), .mem_uncond_branch_out(ex_mem_uncond_branch),
        .mem_reg_branch_in(id_ex_reg_branch), .mem_reg_branch_out(ex_mem_reg_branch),

        // WB stage controls
        .wb_reg_write_in(id_ex_reg_write), .wb_reg_write_out(ex_mem_reg_write),
        .wb_mem_to_reg_in(id_ex_mem_to_reg), .wb_mem_to_reg_out(ex_mem_mem_to_reg),
        .wb_link_write_in(id_ex_link_write), .wb_link_write_out(ex_mem_link_write)
    );

    // MEM: Memory
    // handling pc selector
    logic not_reg_branch, not_uncond_branch;
    logic cond_branch_taken; // high only when a conditional branch and its condition is satisfied

    not #50 not_rb (not_reg_branch, ex_mem_reg_branch);
    not #50 not_ub (not_uncond_branch, ex_mem_uncond_branch);
    and #50 cond_taken_and (cond_branch_taken, ex_mem_take_branch,
                            not_reg_branch, not_uncond_branch, 
                            ex_mem_branch_condition_met);
    or #50 or_pcsrc1 (pc_src[1], ex_mem_reg_branch, cond_branch_taken);
    or #50 or_pcsrc0 (pc_src[0], ex_mem_uncond_branch, ex_mem_reg_branch);

    // data memory
    logic [63:0] mem_read_data;
    datamem dmem (
        .address(ex_mem_alu_result),
        .write_enable(ex_mem_mem_write),
        .read_enable(ex_mem_mem_read),
        .write_data(ex_mem_reg2_data),
        .read_data(mem_read_data),
        .xfer_size(4'b1000),
        .clk(clk)
    );

    // MEM/WB pipeline register
    logic [63:0] mem_wb_alu_result, mem_wb_mem_data, mem_wb_pc_plus4;
    logic [4:0]  mem_wb_rd;
    logic mem_wb_reg_write, mem_wb_mem_to_reg, mem_wb_link_write;

    mem_wb_pipeline_reg mem_wb_reg (
        .clk(clk), .reset(reset), .enable(1'b1),

        // data
        .alu_result_in(ex_mem_alu_result), .alu_result_out(mem_wb_alu_result),
        .mem_data_in(mem_read_data), .mem_data_out(mem_wb_mem_data),
        .rd_in(ex_mem_rd), .rd_out(mem_wb_rd),
        .pc_plus4_in(ex_mem_pc_plus4), .pc_plus4_out(mem_wb_pc_plus4),

        // WB stage control signals
        .wb_reg_write_in(ex_mem_reg_write), .wb_reg_write_out(mem_wb_reg_write),
        .wb_mem_to_reg_in(ex_mem_mem_to_reg), .wb_mem_to_reg_out(mem_wb_mem_to_reg),
        .wb_link_write_in(ex_mem_link_write), .wb_link_write_out(mem_wb_link_write)
    );

    // WB: Write-Back
    // reg write back mux
    logic [63:0] reg_wb;
    mux2_1_64bit reg_wb_mux (.out(reg_wb), .i0(mem_wb_alu_result), .i1(mem_wb_mem_data), .sel(mem_wb_mem_to_reg));
    mux2_1_64bit wb_final (.out(reg_write_data), .i0(reg_wb), .i1(mem_wb_pc_plus4), .sel(mem_wb_link_write));

    // hazard detection unit
    hazard_detection_unit hazard_unit (
        .id_ex_rd(id_ex_rd),
        .id_ex_mem_read(id_ex_mem_read),
        .if_id_r1(selected_R1),
        .if_id_r2(selected_R2),
        .stall(stall)
    );

    // forwarding logic
    logic [1:0] forwardA, forwardB;
    forwarding_unit fwd_unit (
        .id_ex_rn(id_ex_reg1_src),
        .id_ex_rm(id_ex_reg2_src),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_rd(mem_wb_rd),
        .mem_wb_reg_write(mem_wb_reg_write),
        .forwardA(forwardA),
        .forwardB(forwardB)
    );

    mux4_1_64bit fwd_mux_A (
        .i0(id_ex_reg1_data),
        .i1(mem_wb_alu_result), // MEM/WB forwarding
        .i2(ex_mem_alu_result), // EX/MEM forwarding
        .i3(64'd0),
        .sel(forwardA),
        .out(alu_input_a)
    );

    mux4_1_64bit fwd_mux_B (
        .i0(id_ex_reg2_data),
        .i1(mem_wb_alu_result),
        .i2(ex_mem_alu_result),
        .i3(64'd0),
        .sel(forwardB),
        .out(alu_input_b)
    );

    mux2_1_64bit alu_b_mux (.out(input_b), .i0(alu_input_b), .i1(id_ex_imm), .sel(id_ex_alu_src));

    regfile rf_inst (
        .ReadRegister1(selected_R1),      // from ID, Rn vs Rd selected using is_cb_type
        .ReadRegister2(selected_R2),      // from ID, Rm vs Rd selected using reg2loc
        .ReadData1(reg1_data),            // used in ID
        .ReadData2(reg2_data),            // used in ID
        .WriteRegister(mem_wb_rd),        // from WB
        .WriteData(reg_write_data),       // from WB, selected using mem_to_reg
        .RegWrite(mem_wb_reg_write),      // from WB
        .reg_out(regs),
        .clk(clk), .reset(reset)
    );

endmodule

// top level CPU testbench
module cpustim();
    // clock period = 40ns, half-cycle = 20ns
    logic clk = 1'b0;
    localparam int HALF = 20000;
    always  #HALF clk = ~clk;

    logic reset;
    cpu DUT (.clk(clk), .reset(reset));

    // reset active for 5 cycles
    initial begin
      reset = 1'b1;
      repeat (5) @(posedge clk);
      reset = 1'b0;
    end

    // run for 500 instructions
    initial begin
      #(500 * 2 * HALF);
      $display("Finished 800 cycles at %0t ns", $realtime/1000.0);
      $stop;
    end
endmodule
