// top level CPU
`timescale 1ns/10ps

module cpu (
	input logic clk,
	input logic reset
);
	// program counter
	logic [31:0] curr_pc, next_pc;
	pc pc_inst (.clk(clk), .reset(reset), .next_pc(next_pc), .curr_pc(curr_pc));
	
	// instruction memory
	logic [31:0] instruction;
	instructmem imem (
		.address({32'b0, curr_pc}), // zero extend 32 bit PC to 64 bits
		.instruction(instruction),
		.clk(clk)
	);
	
	// control unit
	logic reg_write, alu_src, mem_read, mem_write, mem_to_reg, flag_write, branch, reg2loc;
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
		.branch(branch),
		.reg2loc(reg2loc)
	);
	
	// register file
	logic [4:0] Rd, Rn, Rm;
	assign Rd = instruction[4:0];
	assign Rn = instruction[9:5];
	assign Rm = instruction[20:16];
	
	// choose Rm or Rt for second register
	// reg2loc = 0 (Rm), 1 (Rt)
	logic [4:0] reg2_addr;
	mux2_1_5bit reg2loc_mux (.i0(Rm), .i1(Rd), .sel(reg2loc), .out(reg2_addr));
	
	logic [63:0] reg_read1, reg_read2, reg_write_data;
	regfile regs (
		.ReadRegister1(Rn),
		.ReadRegister2(reg2_addr),
		.WriteRegister(Rd),
		.ReadData1(reg_read1),
		.ReadData2(reg_read2),
		.WriteData(reg_write_data),
		.RegWrite(reg_write),
		.clk(clk)
	);
	
	// immediate generators
	logic [63:0] imm_ext_i, imm_ext_d, imm_ext_b, imm_ext_cb;
	sign_extender_itype ext_i (.in(instruction[21:10]), .out(imm_ext_i));
	sign_extender_dtype ext_d (.in(instruction[20:12]), .out(imm_ext_d));
	sign_extender_btype ext_b (.in(instruction[25:0]), .out(imm_ext_b));
	sign_extender_cbtype ext_cb (.in(instruction[23:5]), .out(imm_ext_cb));
	
	logic [63:0] imm_selected;
	mux4_1_64bit imm_mux (
    .in0(imm_ext_i),    // 00 = I-type
    .in1(imm_ext_d),    // 01 = D/R-type
    .in2(imm_ext_b),    // 10 = B-type
    .in3(imm_ext_cb),   // 11  = CB-type
    .sel(itype),      // 2-bit itype selector
    .out(imm_selected)
	);
	
	// ALU
	logic [63:0] input_a = (itype == 2'b11) ? reg_read2 : reg_read1; // TODO: use mux
	logic [63:0] input_b, alu_result;
	logic zero, negative, overflow, carry_out;
	
	mux2_1_64bit alu_src_mux (.out(input_b), .i0(reg_read2), .i1(imm_selected), .sel(alu_src));
	
	alu alu_inst (
		.A(input_a),
		.B(input_b),
		.cntrl(alu_op),
		.result(alu_result),
		.negative(negative),
		.zero(zero),
		.overflow(overflow),
		.carry_out(carry_out)
	);
	
	// data memory
	logic [63:0] mem_read_data;
	datamem dmem (
		.address(alu_result),
		.write_enable(mem_write),
		.read_enable(mem_read),
		.write_data(reg_read2),
		.clk(clk),
		.xfer_size(4'b1000),
		.read_data(mem_read_data)
	);
	
	mux2_1_64bit write_mux (.out(reg_write_data), .i0(alu_result), .i1(mem_read_data), .sel(mem_to_reg));
	
	// pc update
	assign next_pc = branch ? alu_result : curr_pc + 4; // TODO: remove RTL
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
