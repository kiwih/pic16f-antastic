module hardware_stack #(
	parameter WIDTH = 13,
	parameter TOS_WIDTH = 3
) (
	input wire clk,
	input wire rst,
	input wire pop,
	input wire push,
	input wire [WIDTH - 1:0] in,
	output wire [WIDTH - 1:0] out
);

reg [WIDTH - 1:0] stack [2**TOS_WIDTH - 1:0];

reg [TOS_WIDTH - 1:0] tos = 0;

integer i;

always @(posedge clk) begin
	if(rst) begin
		for(i = 0; i < 2**TOS_WIDTH; i = i+1)
			stack[i] = {WIDTH{1'd0}};
	end else begin
		if(pop) begin
			tos <= tos - 1'd1;
		end else if(push) begin
			stack[tos] <= in;
			tos <= tos + 1'd1;
		end
	end
end
		
assign out = stack[tos - 1'd1];
//todo: finish
endmodule
	