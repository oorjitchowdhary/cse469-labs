// control unit to decode instruction and output control signals

module control_unit (
	input logic [31:0] instruction, //signal that will decide which instruction is being useds
	output logic reg_write,
	output logic alu_src, // 0 = use register, 1 = use immediate
	output logic [2:0] alu_cntrl,
	output logic mem_read,
	output logic mem_write,
	output logic mem_to_reg, // 0 = use ALU result, 1 = use datamem result for regfile WriteData
	output logic flag_write,
	output logic branch,         // for unconditional B
	output logic branch_cond,    // for CBZ or B.LT
	output logic [1:0] pc_src,   // 00 = PC+4, 01 = branch target, 10 = register (BR)
	output logic link            // for BL
);

	logic [10:0] opcode_RD;
	logic [9:0] opcode_I;
	logic [5:0] opcode_B;
	logic [7:0] opcode_CB;
	
	assign opcode_RD = instruction[31:21];
	assign opcode_I = instruction[31:22];
	assign opcode_B  = instruction[31:26];     // B, BL
   assign opcode_CB = instruction[31:24];     // CBZ
	
	always_comb begin
		// defaults
		reg_write = 1'b0;
		alu_src = 1'b0;
		alu_cntrl = 3'b000;
		mem_read = 1'b0;
		mem_write = 1'b0;
		mem_to_reg = 1'b0;
		flag_write = 1'b0;
		branch = 1'b0;
		branch_cond = 1'b0;
		pc_src = 2'b00;
		link = 1'b0;

		
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
		
		//B-type
		case(opcode_B)
		   //B
			6'b000101: begin
			   branch = 1'b1;
				pc_src = 2'b01;
			end
			
			//BL
			6'b100101: begin
			   link = 1'b1;
				pc_src = 2'b01;
			end
		endcase
		
		// CB-type
		case (opcode_CB)
			 8'b10110100: begin  // CBZ
				  branch_cond = 1'b1;
				  pc_src = 2'b01;
			 end
		endcase
		
		if (instruction[31:21] == 11'b11010110000) begin  // BR
			 pc_src = 2'b10; // select register value for PC
		end
		
		// B.LT — conditional branch on N != V
		if (instruction[31:24] == 8'b01010100 && instruction[4:0] == 5'b10100) begin
			 branch_cond = 1'b1;
			 pc_src = 2'b01;
		end


	end
endmodule
