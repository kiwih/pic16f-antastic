module uart_spbrg(
	input wire clk,
	input wire rst,
	
	input wire sync,
	input wire brgh,
	
	input wire spbrg_reg_wr_en,	//baud rate generator
	input wire [7:0] spbrg_reg_in,
	output reg [7:0] spbrg_reg_out,
	
	output reg uart_tx_shift_en,
	
	output wire rx_async_div16_clk //this divides the generated baud rate by 16
);


//SPBRG register
always @(posedge clk) 
	if(rst)
		spbrg_reg_out <= 8'd0;
	else if(spbrg_reg_wr_en)
		spbrg_reg_out <= spbrg_reg_in;

//in asynchronous mode (sync = 0) the baud rate depends on the brgh bit
//if brgh = 0 (low speed), baud rate = Fosc/(64*(spbrg + 1))
//if brgh = 1 (hi  speed), baud rate = Fosc/(16*(spbrg + 1))

//in sync mode (sync = 1) the baud rate does not depend on the brgh bit
//                         baud rate = Fosc/( 4*(spbrg + 1))

reg [7:0] uart_clk_count = 8'd0;
reg [5:0] uart_clk_count_multiplier = 5'd0; //max value = 63

always @(posedge clk) begin
	uart_tx_shift_en <= 1'b0;
	
	if(rst | spbrg_reg_wr_en) begin //on a write to spbrg we need to clear all our counters
		uart_clk_count <= 8'd0;
		uart_clk_count_multiplier <= 5'd0;
	end else begin
		
		uart_clk_count <= uart_clk_count + 8'd1;
		
		if(uart_clk_count == spbrg_reg_out) begin
			uart_clk_count <= 8'd0;
			
			uart_clk_count_multiplier <= uart_clk_count_multiplier + 5'd1;
			
			if((uart_clk_count_multiplier == 6'd15 && brgh == 1'b1 && sync == 1'b0) ||
				(uart_clk_count_multiplier == 6'd63 && brgh == 1'b0 && sync == 1'b0) ||
				(uart_clk_count_multiplier == 6'd3 && sync == 1'b1)) begin
				
				uart_clk_count_multiplier <= 5'd0;
				uart_tx_shift_en <= 1'b1;
			end 
		end
	end
end	

assign rx_async_div16_clk = brgh ? uart_clk_count_multiplier[0] : uart_clk_count_multiplier[2];

endmodule
