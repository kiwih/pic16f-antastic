module test_uart;

reg clk, rst;

initial begin: CLOCK_GENERATOR
	clk = 0;
	forever begin 
		#5 clk = ~clk; //every 5ns invert the clock, so clock period is 10ns = 100MHz
	end
end

reg txsta_reg_wr_en, rcsta_reg_wr_en, spbrg_reg_wr_en, txreg_reg_wr_en, rxreg_reg_wr_en;
reg [7:0] reg_data_in;
wire [7:0] txsta_reg_out;
wire [7:0] rcsta_reg_out;
wire [7:0] spbrg_reg_out;
wire [7:0] txreg_reg_out;
wire [7:0] rxreg_reg_out;

wire txif_set_en, rxif_set_en;

wire UART_TXD, UART_RXD;

uart u(
	.clk(clk),
	.rst(rst),
	
	.UART_TXD(UART_TXD),
	.UART_RXD(UART_RXD),
	
	.reg_data_in(reg_data_in), //the general data in bus
	
	.txsta_reg_wr_en(txsta_reg_wr_en), //transmit status and control
	.txsta_reg_out(txsta_reg_out),
	
	.rcsta_reg_wr_en(rcsta_reg_wr_en), //receive status and control
	.rcsta_reg_out(rcsta_reg_out),
	
	.spbrg_reg_wr_en(spbrg_reg_wr_en),	//baud rate generator
	.spbrg_reg_out(spbrg_reg_out),
	
	.txreg_reg_wr_en(txreg_reg_wr_en),	//transmit register. Setting txreg_reg_wr_en also starts a transmission
	.txreg_reg_out(txreg_reg_out),
	
	.rxreg_reg_wr_en(rxreg_reg_wr_en),	//receive register
	.rxreg_reg_out(rxreg_reg_out),
	
	.txif_set_en(txif_set_en), //strobe to set transmit interrupt flag
									//this is permanently set high unless txreg contains data that has not yet been loaded into the transmit shift register
									//(yes, even as a strobe it's permanently set high - TXIF shouldn't be able to be cleared in software)
									
	.rxif_set_en(rxif_set_en)  //strobe to set receive interrupt flag
);

integer i;

initial begin
	rst = 1;
	reg_data_in = 8'd0;
	txsta_reg_wr_en = 0;
	rcsta_reg_wr_en = 0;
	spbrg_reg_wr_en = 0;
	txreg_reg_wr_en = 0;
	rxreg_reg_wr_en = 0;
	
	#20 //end of reset
	rst = 0;
	assert(txsta_reg_out == 8'b00000010) else $fatal(); //trmt should be high
	assert(txif_set_en == 1) else $fatal(); //txif should be high
	assert(txreg_reg_out == 0) else $fatal();
	assert(spbrg_reg_out == 0) else $fatal();
	assert(u.tsr_state == u.tsr_state_stop) else $fatal();
	assert(UART_TXD == 1) else $fatal();
	assert(u.tsr_enabled == 0) else $fatal(); 
	
	//let's set up a transmit with the fastest baud rate
	reg_data_in = 8'b00100100; //txen = 1, brgh = 1, shift every 16 cycles as spbrg == 0
	txsta_reg_wr_en = 1;
	#10							//timer counter = 1
	txsta_reg_wr_en = 0;
	assert(txsta_reg_out == 8'b00100110) else $fatal(); //txen, brgh, and trmt should be high
	#10							//timer counter = 2
	reg_data_in = 8'b11001010; //the byte to transmit
	txreg_reg_wr_en = 1;
	#10							//timer counter = 3
	txreg_reg_wr_en = 0;
	assert(txreg_reg_out == 8'b11001010) else $fatal();
	assert(txif_set_en == 0) else $fatal(); //txif should have gone low
	assert(u.tsr_state == u.tsr_state_stop) else $fatal();
	#10							//timer counter = 4
	assert(u.tsr_consumed == 1) else $fatal(); //tsr_enabled should have gone high
	assert(u.tsr_enabled == 1) else $fatal(); //tsr_enabled should have gone high
	assert(u.tsr_state == u.tsr_state_stop) else $fatal();
	#10
	assert(txif_set_en == 1) else $fatal(); //txif should have gone high again
	#100							//timer counter = 15
	assert(u.tsr_state == u.tsr_state_stop) else $fatal();
	#10							//timer counter = 0, we take one more cycle to consume it in our fsm
	assert(u.tsr_state == u.tsr_state_stop) else $fatal();
	#10							//timer counter = 1, we now consume the enable signal, every #+160 is good to test from here
	assert(u.tsr_state == u.tsr_state_start) else $fatal();
	assert(UART_TXD == 0) else $fatal();
	
	//now for the data bits:
	#160
	assert(u.tsr_state == u.tsr_state_data) else $fatal();
	assert(UART_TXD == 0) else $fatal();
	#160
	assert(u.tsr_state == u.tsr_state_data) else $fatal();
	assert(UART_TXD == 1) else $fatal();
	#160
	assert(u.tsr_state == u.tsr_state_data) else $fatal();
	assert(UART_TXD == 0) else $fatal();
	#160
	assert(u.tsr_state == u.tsr_state_data) else $fatal();
	assert(UART_TXD == 1) else $fatal();
	#160
	assert(u.tsr_state == u.tsr_state_data) else $fatal();
	assert(UART_TXD == 0) else $fatal();
	#160
	assert(u.tsr_state == u.tsr_state_data) else $fatal();
	assert(UART_TXD == 0) else $fatal();
	#160
	assert(u.tsr_state == u.tsr_state_data) else $fatal();
	assert(UART_TXD == 1) else $fatal();
	#160
	assert(u.tsr_state == u.tsr_state_data) else $fatal();
	assert(UART_TXD == 1) else $fatal();
	
	//now for the stop bit
	#160
	assert(u.tsr_state == u.tsr_state_stop) else $fatal();
	assert(UART_TXD == 1) else $fatal();
	
	

	
	
	
	
	$display("ALL TESTS PASSED SUCCESSFULLY");
	$finish();
end	

endmodule


