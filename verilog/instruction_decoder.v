module instruction_decoder(
	input wire clk,
	
	input wire [13:0] instr_current,
	
	output reg alu_sel_l,
	output reg [3:0] alu_op,
	output reg alu_status_wr_en,
	
	output reg instr_rd_en,
	
	output reg incr_pc_en,
	
	output reg w_reg_wr_en
);

//takes 4 clock cycles to execute a command
//

//most instructions take 4 clock cycles
//1: instruction decode cycle or forced nop
//2: instruction read or nop
//3: process data
//4: instruction write cycle or nop

//imagine that the instruction memory is just full of NOPs
//cycle n-1: NOP loaded into instruction memory register
//cycle n: nothing
//cycle n+1: nothing
//cycle n+2: nothing
//cycle n+3: PC = PC+1

//branch instructions take 8

//



endmodule
