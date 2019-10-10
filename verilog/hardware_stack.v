module hardware_stack #(
	parameter WIDTH = 13,
	parameter TOS_WIDTH = 3
) (
	input wire clk,
	input wire pop,
	input wire push,
	input wire [WIDTH - 1:0] in,
	output wire [WIDTH - 1:0] out
);

reg [WIDTH - 1:0] stack [2**TOS_WIDTH - 1:0];

reg [TOS_WIDTH - 1:0] tos = 0;

always @(posedge clk) begin
	if(pop) begin
		tos <= tos - 1;
	end else if(push) begin
		stack[tos] <= in;
		tos <= tos + 1;
	end
end
		
assign out = stack[tos];
//todo: finish
endmodule
	