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

//TODO: mif

always @(posedge clk)
	if(rst)
		instr = {INSTR_WIDTH{1'b0}};
	else if(rd_en)
		instr = instrMemory[addr];

endmodule

