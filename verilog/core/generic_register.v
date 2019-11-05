module generic_register #(
	parameter WIDTH = 8,
	parameter RESET_VALUE = 8'd0
) (
	input wire clk,
	input wire wr_en,
	input wire rst,
	input wire [WIDTH - 1:0] d,
	output reg [WIDTH - 1:0] q
);

initial q = RESET_VALUE;

always @(posedge clk) begin
	if(rst) begin
		q <= RESET_VALUE;
	end else if(wr_en) begin
		q <= d;
	end
end

endmodule
