// control unit to decode instruction and output control signals

module control_unit (
	input logic [31:0] instruction,
	output logic reg_write,
	output logic alu_src, // 0 = use register, 1 = use immediate
	output logic [2:0] alu_cntrl,
	output logic mem_read,
	output logic mem_write,
	output logic mem_to_reg, // 0 = use ALU result, 1 = use datamem result for regfile WriteData
	output logic flag_write
);

	logic [10:0] opcode_RD;
	logic [9:0] opcode_I;
	logic [5:0] opcode_B;
	logic [7:0] opcode_CB;
	
	assign opcode_RD = instruction[31:21];
	assign opcode_I = instruction[31:22];
	// TODO: B and CB instruction types
	
	always_comb begin
		// defaults
		reg_write = 1'b0;
		alu_src = 1'b0;
		alu_cntrl = 3'b000;
		mem_read = 1'b0;
		mem_write = 1'b0;
		mem_to_reg = 1'b0;
		flag_write = 1'b0;
		
		// R-type or D-type
		case (opcode_RD)
			// ADDS (R)
			11'b10101011000: begin
				reg_write = 1'b1;
				alu_src = 1'b0; // use register
				alu_cntrl = 3'b010; // ALU control code for ADD
				flag_write = 1'b1;
			end
			
			// SUBS (R)
			11'b11101011000: begin
				reg_write = 1'b1;
				alu_src = 1'b0;
				alu_cntrl = 3'b011; // ALU control code for SUB
				flag_write = 1'b1;
			end
			
			// LDUR (D)
			11'b11111000010: begin
				reg_write = 1'b1;
				alu_src = 1'b1;
				alu_cntrl = 3'b010; // ALU to calculate address
				mem_read = 1'b1;
				mem_to_reg = 1'b1;
			end
			
			// STUR (D)
			11'b11111000000: begin
				alu_src = 1'b1;
				alu_cntrl = 3'b010; // ALU to calculate address
				mem_write = 1'b1;
			end
		endcase
		
		// I-type
		case (opcode_I)
			// ADDI
			10'b1001000100: begin
				reg_write = 1'b1;
				alu_src = 1'b1;
				alu_cntrl = 3'b010;
			end
		endcase
	end
endmodule
