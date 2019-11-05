module generic_prescaler #(
	parameter PRESCALER_SEL_WIDTH = 3,
	parameter RESET_VALUE = 8'd0
) (
	//input wire clk,
	input wire rst,
	input wire [PRESCALER_SEL_WIDTH - 1:0] prescaler_sel_in,
	input wire cnt,
	output wire ovf
);

reg unsigned [2**PRESCALER_SEL_WIDTH-1 : 0] counter = 1'd0;
//reg unsigned [PRESCALER_SEL_WIDTH - 1:0] sel_reg = 1'd0;

//capture the positive edges of cnt as cnt_posedge
//reg last_cnt = 1'd0;
//wire cnt_posedge;
//always @(posedge clk) begin
//	if(rst)
//		last_cnt <= 1'd0
//	else
//		last_cnt <= cnt;
//end

//assign cnt_posedge = ~last_cnt & cnt;

always @(posedge cnt, posedge rst) begin
	if(rst) begin
		counter <= 1'd0;
	end else if(cnt) begin
		counter <= counter + 1'd1;
	end 
end

assign ovf = counter[prescaler_sel_in];
//assign prescaler_sel_out = counter;

endmodule
