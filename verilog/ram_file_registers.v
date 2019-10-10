module ram_file_registers #(
	parameter ADDR_WIDTH = 9,
	parameter DATA_WIDTH = 8
) (
	input wire clk,
	input wire [ADDR_WIDTH - 1:0] addr,
	input wire wr_en,
	input wire [DATA_WIDTH - 1:0] data_in,
	output reg [DATA_WIDTH - 1:0] data_out
);

reg [DATA_WIDTH - 1:0] dataMemory [2**ADDR_WIDTH - 1:0];

always @(posedge clk) begin
	if(wr_en) begin
		dataMemory[addr] <= data_in;
	end
	data_out <= dataMemory[addr];
end

endmodule

