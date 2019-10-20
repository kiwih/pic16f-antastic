module generic_prescaler #(
	parameter PRESCALER_SEL_WIDTH = 3,
	parameter RESET_VALUE = 8'd0
) (
	input wire clk,
	input wire rst,
	input wire prescaler_sel_wr_en,
	input wire [PRESCALER_SEL_WIDTH - 1:0] prescaler_sel_in,
	output wire [PRESCALER_SEL_WIDTH - 1:0] prescaler_sel_out,
	input wire cnt,
	output wire ovf
);

reg unsigned [2**PRESCALER_SEL_WIDTH-1 : 0] counter = 1'd0;
reg unsigned [PRESCALER_SEL_WIDTH - 1:0] sel_reg = 1'd0;

always @(posedge clk) begin
	if(rst) begin
		counter <= 1'd0;
	end else if(cnt) begin
		counter <= counter + 1'd1;
	end 
end

always @(posedge clk) begin
	if(rst) begin
		sel_reg <= 1'd0;
	end else if(prescaler_sel_wr_en) begin
		sel_reg <= prescaler_sel_in;
	end
end

assign ovf = counter[sel_reg];
assign prescaler_sel_out = counter;

endmodule
