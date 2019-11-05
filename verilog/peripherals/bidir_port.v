module bidir_port#(
	parameter WIDTH = 8,
	parameter RESET_VALUE = 8'd0
) (
	input wire clk,
	input wire rst,
	
	inout wire [WIDTH - 1:0] physical, //external values (inputs)
	
	output reg [WIDTH - 1:0] tris, //external output enable (if true, set as input for that position)
	output wire [WIDTH - 1:0] port, 
	
	input wire [WIDTH - 1:0] tris_in,
	input wire tris_wr_en,
	input wire [WIDTH - 1:0] port_in,
	input wire port_wr_en
);

reg [7:0] port_i;
reg [7:0] port_tmp;
		
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

genvar i;
generate
	for(i = 0; i < WIDTH; i = i + 1) begin:bidir_control
		assign physical[i] = tris[i] ? 1'bz : port_i[i];
		
		always @(posedge clk) 
			port_tmp[i] <= physical[i];
	end
endgenerate


assign port = port_tmp;
endmodule
