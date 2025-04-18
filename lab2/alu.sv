module alu (
	input logic	 [63:0]	A, B;
	output logic [2:0]	cntrl;
	output logic [63:0]	result;
	output logic negative, zero, overflow, carry_out ;
);

   

