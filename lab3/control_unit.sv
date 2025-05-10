// control unit to decode instruction and output control signals

module control_unit (
	input logic [31:0] instruction, // signal that will decide which instruction is being used
	output logic [1:0] itype, // 00 = I, 01 = D/R, 10 = B, 11 = CB
	output logic reg_write,
	output logic alu_src, // 0 = use register, 1 = use immediate
	output logic [2:0] alu_op,
	output logic mem_read,
	output logic mem_write,
	output logic mem_to_reg, // 0 = use ALU result, 1 = use datamem result for regfile WriteData
	output logic flag_write,
	output logic branch, // 0 = no branch to be used, 1 = use branch address
	output logic reg2loc // 0 = use Rm (ALU ops), 1 = use Rt (STUR/CBZ/CBNZ)
);

	logic [10:0] opcode_RD;
	logic [9:0] opcode_I;
	logic [5:0] opcode_B;
	logic [7:0] opcode_CB;
	
	assign opcode_RD = instruction[31:21];
	assign opcode_I = instruction[31:22];
   assign opcode_CB = instruction[31:24];
	assign opcode_B  = instruction[31:26];
	
	always_comb begin
		// defaults
		reg_write = 1'b0;
		alu_src = 1'b0;
		alu_op = 3'b000;
		mem_read = 1'b0;
		mem_write = 1'b0;
		mem_to_reg = 1'b0;
		flag_write = 1'b0;
		itype = 2'b00;
		branch = 1'b0;
		reg2loc = 1'b0;
		
		// R-type or D-type
		case (opcode_RD)
			// ADDS (R)
			11'b10101011000: begin
				itype = 2'b01; // don't care selector
				reg_write = 1'b1;
				alu_src = 1'b0; // use register
				alu_op = 3'b010; // ALU ADD
				flag_write = 1'b1;
			end
			
			// SUBS (R)
			11'b11101011000: begin
				itype = 2'b01; // don't care selector
				reg_write = 1'b1;
				alu_src = 1'b0;
				alu_op = 3'b011; // ALU SUB
				flag_write = 1'b1;
			end
			
			// BR (R)
			11'b11010110000: begin
				itype = 2'b01; // don't care selector
				branch = 1'b1;
				alu_op = 3'b000; // ALU pass B
			end
			
			// LDUR (D)
			11'b11111000010: begin
				itype = 2'b01; // D-type selector
				reg_write = 1'b1;
				alu_src = 1'b1;
				alu_op = 3'b010; // ALU ADD to calculate target address
				mem_read = 1'b1;
				mem_to_reg = 1'b1;
			end
			
			// STUR (D)
			11'b11111000000: begin
				itype = 2'b01; // D-type selector
				alu_src = 1'b1;
				alu_op = 3'b010; // ALU ADD to calculate target address
				mem_write = 1'b1;
				reg2loc = 1'b1;
			end
		endcase
		
		// I-type
		case (opcode_I)
			// ADDI
			10'b1001000100: begin
				itype = 2'b00; // I-type selector
				reg_write = 1'b1;
				alu_src = 1'b1;
				alu_op = 3'b010; // ALU ADD
			end
		endcase

		// CB-type
		case (opcode_CB)
			// CBZ 
			8'b10110100: begin
				itype = 2'b11; // CB-type selector
				branch = 1'b1;
				alu_op = 3'b000; // ALU pass B
				reg2loc = 1'b1;
			end
			
			// B.LT
			8'b01010100: if (instruction[4:0] == 5'b01011) begin
				itype = 2'b11; // CB-type selector
				branch = 1'b1;
			end
		endcase
		
		// B-type
		case (opcode_B)
			// B
			6'b000101: begin
				itype = 2'b10; // B-type selector
				branch = 1'b1;
			end
			
			// BL
			6'b100101: begin
				itype = 2'b10;
				branch = 1'b1;
				reg_write = 1'b1;
			end
		endcase
	end
endmodule
