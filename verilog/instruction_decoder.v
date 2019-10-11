module instruction_decoder(
	input wire clk,
	
	input wire [13:0] instr_current,
	
	output wire instr_rd_en
);

//takes 4 clock cycles to execute a command
//

//most instructions take 4 clock cycles
//1: instruction decode cycle or forced nop
//2: instruction read or nop
//3: process data
//4: instruction write cycle or nop

//branch instructions take 8

//



endmodule
