// fake_bidir_port
// Hammond Pearce, 2019
// this peripheral may be used to generate a bidirectional port for the processor
//note:
//this does not actually have any inouts (hence the fake)
//however, you can make it be a real bidir port by using the physical_in, physical_out and tris connections externally and at the top level

module fake_bidir_port#(
	parameter WIDTH = 8,
	parameter RESET_VALUE = 8'd0
) (
	input wire clk,
	input wire rst,
	
	input wire [WIDTH - 1:0] physical_in,
	output wire [WIDTH - 1:0] physical_out,
	
	output reg [WIDTH - 1:0] tris, //external output enable (if true, set as input for that position)
	output reg [WIDTH - 1:0] port, 
	
	input wire [WIDTH - 1:0] tris_in,
	input wire tris_wr_en,
	input wire [WIDTH - 1:0] port_in,
	input wire port_wr_en
);

reg [7:0] port_i;
		
always @(posedge clk) begin
	if(rst)
		tris <= RESET_VALUE;
	else if (tris_wr_en)
		tris <= tris_in;
end

always @(posedge clk) begin
	if(rst)
		port_i <= RESET_VALUE;
	else if (port_wr_en)
		port_i <= port_in;
end

integer i;
always @*
	for(i = 0; i < WIDTH; i = i + 1)
		port[i] <= tris[i] ? physical_in[i] : port_i[i];

assign physical_out = port;
endmodule
