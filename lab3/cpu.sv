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
	logic reg_write, alu_src, mem_read, mem_write, mem_to_reg, flag_write;
	logic [2:0] alu_op;
	control_unit ctrl (
		.instruction(instruction),
		.reg_write(reg_write),
		.alu_src(alu_src),
		.alu_op(alu_op),
		.mem_read(mem_read),
		.mem_write(mem_write),
		.mem_to_reg(mem_to_reg),
		.flag_write(flag_write)
	);
	
	// register file
	logic [4:0] Rd, Rn, Rm;
	assign Rd = instruction[4:0];
	assign Rn = instruction[9:5];
	assign Rm = instruction[20:16];
	
	logic [63:0] reg_read1, reg_read2, reg_write_data;
	regfile regs (
		.ReadRegister1(Rn),
		.ReadRegister2(Rm),
		.WriteRegister(Rd),
		.ReadData1(reg_read1),
		.ReadData2(reg_read2),
		.WriteData(reg_write_data),
		.RegWrite(reg_write),
		.clk(clk)
	);
	
	// sign extender
	logic [63:0] imm_ext;
	logic is_d_type;
   assign is_d_type = (instruction[31:21] == 11'b11111000010 || instruction[31:21] == 11'b11111000000);
	
	immediate_gen imm_gen (
		.instruction(instruction),
		.is_d_type(is_d_type),
		.imm_out(imm_ext)
	);
	
	// ALU
	logic [63:0] input_b, alu_result;
	logic zero, negative, overflow, carry_out;
	
	mux2_1_64bit alu_src_mux (.out(input_b), .i0(reg_read2), .i1(imm_ext), .sel(alu_src));
	
	alu alu_inst (
		.A(reg_read1),
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
	assign next_pc = curr_pc + 4;
endmodule

// CPU testbench
module cpu_tb;

    logic clk, reset;
    cpu DUT (.clk(clk), .reset(reset));

    initial begin
        clk = 0;
        forever #250 clk = ~clk;  // 500 ns period
    end

    initial begin
        reset = 1;
        #1000;
        reset = 0;

        // Run for enough cycles (adjust if needed)
        repeat (200) @(posedge clk);
        $stop;
    end

endmodule
