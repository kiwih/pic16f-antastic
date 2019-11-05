module fake_bidir_port#(
	parameter WIDTH = 8,
	parameter RESET_VALUE = 8'd0
) (
	input wire clk,
	input wire rst,
	
//	inout wire [WIDTH - 1:0] physical, //external values (inputs)
	input wire [WIDTH - 1:0] physical_in,
	output wire [WIDTH - 1:0] physical_out,
	
	output reg [WIDTH - 1:0] tris, //external output enable (if true, set as input for that position)
	output reg [WIDTH - 1:0] port, 
	
	input wire [WIDTH - 1:0] tris_in,
	input wire tris_wr_en,
	input wire [WIDTH - 1:0] port_in,
	input wire port_wr_en
);

//integer i;
//always @(*)
//	for(i = 0; i < WIDTH; i = i+1)
//		physical[i] = tris[i] ? 1'bZ : port[i];

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
