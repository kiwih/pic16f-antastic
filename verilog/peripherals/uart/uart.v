//uart (this peripheral) is for asynchronous uart in the pic16f-antastic
// Hammond Pearce, 2019
//Note that it doesn't support Synchronous Mode USART,
// and as such the following bits are set permanently:
// TXSTA[7] (CSRC) is read only and set to 0 permanently (async doesn't care)
// TXSTA[4] (SYNC) is read only and set to 0 permanently (force async mode)
// RCSTA[5] (SREN) is read only and set to 0 permanently (async doesn't care)

//also, i honestly don't know if this can be represented simpler than presented. It probably can,
//but there's a lot of crazy interaction between modules in this system which are difficult to capture concisely

module uart(
	input wire clk,
	input wire rst,
	
	output reg UART_TXD,
	input wire UART_RXD,
	
	input wire [7:0] reg_data_in, //the general data in bus
	
	input wire txsta_reg_wr_en, //transmit status and control
	output wire [7:0] txsta_reg_out,
	
	input wire rcsta_reg_wr_en, //receive status and control
	output reg [7:0] rcsta_reg_out,
	
	input wire spbrg_reg_wr_en,	//baud rate generator
	output wire [7:0] spbrg_reg_out,
	
	input wire txreg_reg_wr_en,	//transmit register. Setting txreg_reg_wr_en also starts a transmission
	output wire [7:0] txreg_reg_out,
	
	input wire rxreg_reg_wr_en,	//receive register
	output reg [7:0] rxreg_reg_out,
	
	output reg txif_set_en, //strobe to set transmit interrupt flag
									//this is permanently set high unless txreg contains data that has not yet been loaded into the transmit shift register
									//(yes, even as a strobe it's permanently set high - TXIF shouldn't be able to be cleared in software)
									
	output reg rxif_set_en  //strobe to set receive interrupt flag
);

//TXSTA, TXREG, and TSR registers

wire csrc = 1'b0; //forced zero always, feature is unimplemented
reg tx9 = 1'b0;
reg txen = 1'b0;
wire sync = 1'b0; //forced zero always, feature is unimplemented
reg brgh = 1'b0;
reg tx9d = 1'b0;


reg [7:0] txreg = 8'd0;
assign txreg_reg_out = txreg;

reg trmt = 1'b1; //is set to 0 if tsr is doing stuff, 1 otherwise

assign txsta_reg_out = {csrc, tx9, txen, sync, 1'b0, brgh, trmt, tx9d};
always @(posedge clk) begin
	if(rst) begin
		tx9 <= 1'd0;
		txen <= 1'd0;
		brgh <= 1'd0;
		tx9d <= 1'd0;
	end else if(txsta_reg_wr_en) begin
		tx9 <= reg_data_in[6];
		txen <= reg_data_in[5];
		brgh <= reg_data_in[2];
		tx9d <= reg_data_in[0];
	end
end

//txreg
reg tsr_consumed = 1'b0;	//we'll use this signal to pass a message back to txreg that its contents are consumed
always @(posedge clk) begin
	if(rst) begin
		txif_set_en <= 1'b1;
		txreg <= 8'd0;
	end else if(txreg_reg_wr_en) begin
		txreg <= reg_data_in;
		txif_set_en <= 1'b0; //mark transmission ready by setting txif low)							
	end else if(tsr_consumed) begin //TSR has sent back a signal to indicate we can overwrite txreg
		txif_set_en <= 1'b1;	
	end
end

wire uart_tx_shift_en;
wire uart_rx_cap_en;

uart_spbrg spbrg(
	.clk(clk),
	.rst(rst),
	
	.sync(sync), //sync is unimplemented and reads as 0
	.brgh(brgh),
	
	.spbrg_reg_wr_en(spbrg_reg_wr_en),	
	.spbrg_reg_in(reg_data_in),
	.spbrg_reg_out(spbrg_reg_out),
	
	.uart_tx_shift_en(uart_tx_shift_en),
	
	.uart_rx_cap_en(uart_rx_cap_en)
);

//TSR shift register system
reg [8:0] tsr = 9'd0;
reg [2:0] tsr_count = 3'd0; //for counting data bits

localparam tsr_state_stop  = 3'd0;
localparam tsr_state_start = 3'd1;
localparam tsr_state_data  = 3'd2;
localparam tsr_state_tx9   = 3'd3;

reg tsr_enabled = 1'b0;
reg [2:0] tsr_state = tsr_state_stop;

always @(posedge clk) begin
	tsr_consumed <= 1'b0; //this is the feedback signal to the txreg that we've consumed its input
	
	if(rst) begin
		tsr <= 9'd0;
		trmt <= 1'b1;
		tsr_count <= 3'd0;
		tsr_state <= tsr_state_stop;
		tsr_enabled <= 1'b0;
	end else begin
		if(txen) begin
			case(tsr_state)
				tsr_state_stop: begin
					trmt <= 1'b1;
					if(txif_set_en == 1'b0) begin //a transmission is ready
						trmt <= 1'b0;
						tsr_consumed <= 1'b1;
						tsr <= {tx9d, txreg};
						tsr_enabled = 1'b1;
					end
					if(tsr_enabled && uart_tx_shift_en) begin
						trmt <= 1'b0;
						tsr_state <= tsr_state_start;
						tsr_enabled <= 1'b0;
					end
				end
				tsr_state_start: begin
					if(uart_tx_shift_en)
						tsr_state <= tsr_state_data;
					trmt <= 1'b0;
				end
				tsr_state_data: begin
					trmt <= 1'b0;
					
					if(uart_tx_shift_en && tsr_count == 3'd7)
						tsr_state <= tx9 ? tsr_state_tx9 : tsr_state_stop;

					if(uart_tx_shift_en) begin
						tsr <= {1'b0, tsr[8:1]};
						tsr_count <= tsr_count + 3'd1;
					end
				end
				tsr_state_tx9: begin
					if(uart_tx_shift_en)
						tsr_state <= tsr_state_stop;
					trmt <= 1'b0;
					tsr <= {1'b0, tsr[8:1]};
				end
			endcase
		end
	end
end

always @* begin
	UART_TXD <= 1'b1; //rest the TX line at 1 (idle)

	case(tsr_state)
		tsr_state_stop: begin
		end
		tsr_state_start: begin
			UART_TXD <= 1'd0;
		end
		tsr_state_data: begin
			UART_TXD <= tsr[0];
		end
		tsr_state_tx9: begin
			UART_TXD <= tsr[0];
		end
	endcase
end
endmodule
