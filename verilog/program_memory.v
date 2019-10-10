module program_memory #(
	parameter ADDR_WIDTH = 13,
	parameter INSTR_WIDTH = 14
) (
	input wire clk,
	input wire [ADDR_WIDTH - 1:0] addr,
	output reg [INSTR_WIDTH - 1:0] instr
);

reg [INSTR_WIDTH - 1:0] instrMemory [2**ADDR_WIDTH - 1:0];

//TODO: mif

always @(posedge clk)
	instr = instrMemory[addr];

endmodule

