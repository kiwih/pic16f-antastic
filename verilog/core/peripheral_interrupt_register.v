module peripheral_interrupt_register #(
	parameter WIDTH = 8,
	parameter RESET_VALUE = 8'd0,
	parameter INTERRUPTS_AS_STROBES = 8'b11001111 //if 1, it's a strobe. If 0, it's readonly
) (
	input wire clk,
	input wire wr_en,
	input wire rst,
	input wire [WIDTH - 1:0] interrupt_strobes,
	input wire [WIDTH - 1:0] interrupt_readonlys,
	input wire [WIDTH - 1:0] d,
	output wire [WIDTH - 1:0] q
);

reg [WIDTH - 1:0] q_i;

integer i;
always @(posedge clk) begin
	if(rst) begin
		q_i <= RESET_VALUE;
	end else begin
		if(wr_en) 
			q_i <= d;
		for(i = 0; i < (WIDTH); i=i+1)
			if(interrupt_strobes[i] && INTERRUPTS_AS_STROBES[i])
				q_i[i] = 1'b1;
	end
end

genvar j;
generate
	for(j = 0; j < (WIDTH); j=j+1) begin:OUT_PIR
		assign q[j] = INTERRUPTS_AS_STROBES[j] ? q_i[j] : interrupt_readonlys[j];
	end
endgenerate

endmodule
