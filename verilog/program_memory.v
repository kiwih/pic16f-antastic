module program_memory #(
	parameter ADDR_WIDTH = 13,
	parameter INSTR_WIDTH = 14
) (
	input wire clk,
	input wire rst,
	input wire rd_en,
	input wire [ADDR_WIDTH - 1:0] addr,
	output reg [INSTR_WIDTH - 1:0] instr
);

reg [INSTR_WIDTH - 1:0] instrMemory [2**ADDR_WIDTH - 1:0];

initial begin
	instr = {INSTR_WIDTH{1'b0}};
	
   instrMemory[0] = 14'b00_0000_0000_0000; //nop
	instrMemory[1] = 14'b11_0000_1010_1011; //movlw 0xAB
	instrMemory[2] = 14'b10_1000_0000_0000; //goto 0x000
end

//TODO: mif

always @(posedge clk)
	if(rst)
		instr = {INSTR_WIDTH{1'b0}};
	else if(rd_en)
		instr = instrMemory[addr];

endmodule

