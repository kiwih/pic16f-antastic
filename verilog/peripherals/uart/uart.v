//uart (this peripheral) is for asynchronous uart in the pic16f-antastic
// Hammond Pearce, 2019
//Note that it doesn't support Synchronous Mode USART,
// and as such the following bits are set permanently:
// TXSTA[7] (CSRC) is read only and set to 0 permanently (async doesn't care)
// TXSTA[4] (SYNC) is read only and set to 0 permanently (force async mode)
// RCSTA[7] (SPEN) is read only and set to 1 permanently ("forces" UART TXD/RXD pins to be available, but we won't mux them with portb)
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
	output wire [7:0] rcsta_reg_out,
	
	input wire spbrg_reg_wr_en,	//baud rate generator
	output wire [7:0] spbrg_reg_out,
	
	input wire txreg_reg_wr_en,	//transmit register. Setting txreg_reg_wr_en also starts a transmission
	output wire [7:0] txreg_reg_out,
	
	input wire rcreg_reg_rd_en,	//receive register
	output wire [7:0] rcreg_reg_out,
	
	output reg txif_set_en, //strobe to set transmit interrupt flag
									//this is permanently set high unless txreg contains data that has not yet been loaded into the transmit shift register
									//(yes, even as a strobe it's permanently set high - TXIF shouldn't be able to be cleared in software)
									
	output reg rxif_set_en  //strobe to set receive interrupt flag
);

//TXSTA, TXREG, and TSR registers

wire csrc = 1'b0; //forced zero always, feature is unimplemented
reg tx9 = 1'b0; //9 bit transmit mode
reg txen = 1'b0; //transmite enabled
wire sync = 1'b0; //forced zero always, feature is unimplemented
reg brgh = 1'b0; //baud rate generator high speed mode
reg tx9d = 1'b0; //data bit for 9 bit mode


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
wire uart_rx_async_div16_en;

uart_spbrg spbrg(
	.clk(clk),
	.rst(rst),
	
	.sync(sync), //sync is unimplemented and reads as 0
	.brgh(brgh),
	
	.spbrg_reg_wr_en(spbrg_reg_wr_en),	
	.spbrg_reg_in(reg_data_in),
	.spbrg_reg_out(spbrg_reg_out),
	
	.uart_tx_shift_en(uart_tx_shift_en),
	
	.uart_rx_async_div16_en(uart_rx_async_div16_en)
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

//----------------------------------------------------------receiving system-----------------------------------------

//TXSTA, TXREG, and TSR registers

wire spen = 1'b1; //permanently enabled (tx/rx are permanently enabled and not muxed with anything)
reg rx9 = 1'b0; //9 bit rx mode
wire sren = 1'b0; //permanently disabled
reg cren = 1'b0; //continuous receive enable bit
reg aden = 1'b0; //address detect enable bit
wire ferr; //framing error
reg oerr = 1'b0; //overrun error
wire rx9d; //data bit for 9 bit mode

assign rcsta_reg_out = {spen, rx9, sren, cren, aden, ferr, oerr, rx9d};
always @(posedge clk) begin
	if(rst) begin
		rx9 <= 1'd0;
		cren <= 1'd0;
		aden <= 1'd0;
	end else if(rcsta_reg_wr_en) begin
		rx9 <= reg_data_in[6];
		cren <= reg_data_in[4];
		aden <= reg_data_in[3];
	end
end

reg [7:0] rsr = 8'd0;
reg rsr_rx9d = 1'd0;
reg rsr_ferr = 1'd0;
reg rcreg_reg_wr_en = 1'd0;

localparam rsr_state_idle  = 3'd0;
localparam rsr_state_start = 3'd1;
localparam rsr_state_data  = 3'd2;
localparam rsr_state_rx9   = 3'd3;
localparam rsr_state_stop	= 3'd4;

reg [2:0] rsr_state = rsr_state_idle;

reg [2:0] rsr_bit_count;
reg [3:0] rsr_cycle_count;

reg [2:0] rsr_majority_cap;

always @(posedge clk) begin
	rcreg_reg_wr_en <= 1'd0;
	if(rst) begin
		rsr_state <= rsr_state_idle;
		
		rsr_bit_count <= 4'd0;
		rsr_cycle_count <= 4'd0;
		rsr_rx9d <= 1'd0;
		rsr_ferr <= 1'd0;
		rsr <= 8'd0;
		rsr_majority_cap <= 3'd0;
	end else begin
		
		if(cren && !oerr) begin //an overrun error is supposed to inhibit functionality until cren is reset, oerr is managed by rcreg
			
			//todo: the rest of the functionality here
			//the trick is timing/capturing the bits
			//use the uart_rx_async_div16_en to keep everything on track (probably i'll need to convert this to a strobe like the shift for the tx)
			//rcreg is a fifo, unbelievably, which means I need a read signal - something that isn't yet propagated from the core! Unbelievable
			
			case(rsr_state) 
				rsr_state_idle: begin
					if(UART_RXD == 1'b0 && uart_rx_async_div16_en) begin
						rsr_state <= rsr_state_start;
						
						rsr_bit_count <= 4'd0;
						rsr_cycle_count <= 4'd0;
						rsr_rx9d <= 1'b0;
						rsr_ferr <= 1'b0;
						rsr <= 8'd0;
						rsr_majority_cap <= 3'd0;
					end
				end
				rsr_state_start: begin
					if(uart_rx_async_div16_en) begin
						rsr_cycle_count <= rsr_cycle_count + 4'd1;
						if(rsr_cycle_count == 4'd15) begin
							rsr_state <= rsr_state_data;
							rsr_cycle_count <= 1'd0;
						end 
					end
				end
				rsr_state_data: begin
					if(uart_rx_async_div16_en) begin
						rsr_cycle_count <= rsr_cycle_count + 4'd1;
						
						if(rsr_cycle_count == 4'd7) begin
							rsr_majority_cap[0] <= UART_RXD;
						end else if(rsr_cycle_count == 4'd8) begin
							rsr_majority_cap[1] <= UART_RXD;
						end else if(rsr_cycle_count == 4'd9) begin
							rsr_majority_cap[2] <= UART_RXD;
							
						end else if(rsr_cycle_count == 4'd10) begin
							rsr <= {(rsr_majority_cap[0] & rsr_majority_cap[1]) |
									  (rsr_majority_cap[1] & rsr_majority_cap[2]) |
									  (rsr_majority_cap[2] & rsr_majority_cap[0]) ,
									  rsr[7:1]};
									  
						end else if(rsr_cycle_count == 4'd15) begin
							rsr_cycle_count <= 4'd0;
							
							rsr_bit_count <= rsr_bit_count + 3'd1;
							
							if(rsr_bit_count == 3'd7) begin
								rsr_bit_count <= 3'd0;
								if(rx9) begin
									rsr_state <= rsr_state_rx9;
								end else begin
									rsr_state <= rsr_state_stop;
								end
							end
						end
					end
				end
				rsr_state_rx9: begin
					if(uart_rx_async_div16_en) begin
						rsr_cycle_count <= rsr_cycle_count + 4'd1;
						
						if(rsr_cycle_count == 4'd7) begin
							rsr_majority_cap[0] <= UART_RXD;
						end else if(rsr_cycle_count == 4'd8) begin
							rsr_majority_cap[1] <= UART_RXD;
						end else if(rsr_cycle_count == 4'd9) begin
							rsr_majority_cap[2] <= UART_RXD;
							
						end else if(rsr_cycle_count == 4'd10) begin
							rsr_rx9d <= (rsr_majority_cap[0] & rsr_majority_cap[1]) |
											(rsr_majority_cap[1] & rsr_majority_cap[2]) |
											(rsr_majority_cap[2] & rsr_majority_cap[0]);
									  
						end else if(rsr_cycle_count == 4'd15) begin
							rsr_cycle_count <= 4'd0;
							
							rsr_state <= rsr_state_stop;
						end
					end
				end
				rsr_state_stop: begin
					if(uart_rx_async_div16_en) begin
						rsr_cycle_count <= rsr_cycle_count + 4'd1;
						
						if(rsr_cycle_count == 4'd7) begin
							rsr_majority_cap[0] <= UART_RXD;
						end else if(rsr_cycle_count == 4'd8) begin
							rsr_majority_cap[1] <= UART_RXD;
						end else if(rsr_cycle_count == 4'd9) begin
							rsr_majority_cap[2] <= UART_RXD;
							
						end else if(rsr_cycle_count == 4'd10) begin
							//no framing error when a majority votes "1" during the stop bit
							rsr_ferr <= !((rsr_majority_cap[0] & rsr_majority_cap[1]) |
										     (rsr_majority_cap[1] & rsr_majority_cap[2]) |
										     (rsr_majority_cap[2] & rsr_majority_cap[0]));
							
							//and now we're done
							rcreg_reg_wr_en <= 1'd1;
							rsr_cycle_count <= 4'd0;
							rsr_state <= rsr_state_idle;
						end
					end
				end
			endcase
		end	
	end
end

reg [9:0] rcreg [0:1]; //rcreg is a 2-length fifo. Bits 7:0, rx byte; bit 8, rx bit 9; bit 9, ferr bit
reg rcreg_rd_pos = 1'b0;
reg rcreg_wr_pos = 1'b0;
reg [1:0] rcreg_count = 2'd0;

assign rcreg_reg_out = rcreg[rcreg_rd_pos][7:0];
assign rx9d = rcreg[rcreg_rd_pos][8];
assign ferr = rcreg[rcreg_rd_pos][9];

//rcreg
always @(posedge clk) begin
	if(rst) begin
		rcreg[0] <= 10'd0;
		rcreg[1] <= 10'd0;
		rcreg_rd_pos <= 1'b0;
		rcreg_wr_pos <= 1'b0;
		rcreg_count = 2'd0;
		oerr <= 1'd0;
	end else if(!cren) begin
		oerr <= 1'b0;
	end else begin
	
		if(rcreg_reg_rd_en) begin
			rcreg[rcreg_rd_pos] <= 10'd0;
			rcreg_rd_pos <= rcreg_rd_pos + 1'b1;
			if(rcreg_count > 2'd0)
				rcreg_count = rcreg_count - 2'd1;
		end
		if(rcreg_reg_wr_en)	begin
			if(rcreg_count < 2'd2) begin
				rcreg_count = rcreg_count + 2'd1;
				rcreg[rcreg_wr_pos] <= {rsr_ferr, rsr_rx9d, rsr};
				rcreg_wr_pos <= rcreg_wr_pos + 1'b1;
			end else begin 
				oerr <= 1'b1; //we're fully booked - there's no room in the inn [fifo]!
			end
		end
	end
end

//RCIF is set when the "receive buffer is full" (in non-ADEN mode)
//we can tell if the "receive buffer [rcreg]" is full when rcreg_rd_pos and rcreg_wr_pos are different
always @* begin
	rxif_set_en <= 1'b0;
	if (!aden && rcreg_count != 2'd0) begin
		rxif_set_en <= 1'b1;
	end //todo ELSE IF ADEN, there's a bunch of logic in here
end
		
		
endmodule
