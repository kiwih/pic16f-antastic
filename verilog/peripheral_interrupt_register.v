module peripheral_interrupt_register #(
	parameter WIDTH = 8,
	parameter RESET_VALUE = 8'd0
) (
	input wire clk,
	input wire wr_en,
	input wire rst,
	input wire [WIDTH - 1:0] interrupt_strobes,
	input wire [WIDTH - 1:0] d,
	output reg [WIDTH - 1:0] q
);

initial q = RESET_VALUE;

integer i;
always @(posedge clk) begin
	if(rst) begin
		q <= RESET_VALUE;
	end else begin
		if(wr_en) 
			q <= d;
		for(i = 0; i < (WIDTH-1); i=i+1)
			if(interrupt_strobes[i])
				q[i] = 1'b1;
	end
end

endmodule
