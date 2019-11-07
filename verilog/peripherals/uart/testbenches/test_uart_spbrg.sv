module test_uart_spbrg;

reg clk, rst;

initial begin: CLOCK_GENERATOR
	clk = 0;
	forever begin 
		#5 clk = ~clk; //every 5ns invert the clock, so clock period is 10ns = 100MHz
	end
end

reg sync, brgh, spbrg_reg_wr_en;
reg [7:0] spbrg_reg_in;
wire spbrg_reg_out;
wire uart_tx_shift_en;

uart_spbrg spbrg(
	.clk(clk),
	.rst(rst),
	
	.sync(sync),
	.brgh(brgh),
	
	.spbrg_reg_wr_en(spbrg_reg_wr_en),	
	.spbrg_reg_in(spbrg_reg_in),
	.spbrg_reg_out(spbrg_reg_out),
	
	.uart_tx_shift_en(uart_tx_shift_en)
);

integer i;

initial begin
	rst = 1;
	sync = 0;//we're never going to have any other value for this, we're not interested in synchronous mode
	brgh = 0; //initially we test at low speed (so /64)
	
	#20 //end of reset
	rst = 0;
	assert(spbrg.uart_clk_count == 0) else $fatal();
	assert(spbrg.uart_clk_count_multiplier == 0) else $fatal();
	assert(spbrg_reg_out == 0) else $fatal();
	assert(uart_tx_shift_en == 0) else $fatal();
	
	//in asynchronous mode (sync = 0) the baud rate depends on the brgh bit
	//if brgh = 0 (low speed), baud rate = Fosc/(64*(spbrg + 1))
	//if brgh = 1 (hi  speed), baud rate = Fosc/(16*(spbrg + 1))

	//in sync mode (sync = 1) the baud rate does not depend on the brgh bit
	//                         baud rate = Fosc/( 4*(spbrg + 1))
	
	//given current settings, the uart_tx_shift_en shoul go high for 1 cycle every 64 cycles, and each cycle takes 10 cycles, so....
	//test spbrg=0 with brgh = 0
	#630
	assert(uart_tx_shift_en == 0) else $fatal();
	#10
	assert(uart_tx_shift_en == 1) else $fatal();
	#10
	assert(uart_tx_shift_en == 0) else $fatal();
	#630
	assert(uart_tx_shift_en == 1) else $fatal();
	
	//test spbrg=1 with brgh = 0
	spbrg_reg_wr_en <= 1;
	spbrg_reg_in <= 8'd1; //now it should take 128 cycles
	#10
	spbrg_reg_wr_en <= 0; //being 1 reset the counters, so we now start counting again from zero to 128 cycles
	#640
	assert(uart_tx_shift_en == 0) else $fatal();
	#640 
	assert(uart_tx_shift_en == 1) else $fatal();
	
	//test spbrg=1 with brgh = 1
	brgh <= 1; //now it should take 32 cycles
	#310
	assert(uart_tx_shift_en == 0) else $fatal();
	#10
	assert(uart_tx_shift_en == 1) else $fatal();
	
	//test spbrg=0 with brgh = 1
	//now it should take 16 cyles
	spbrg_reg_wr_en <= 1;
	spbrg_reg_in <= 8'd0; 
	#10
	spbrg_reg_wr_en <= 0; //being 1 reset the counters, so we now start counting again from zero to 16 cycles
	#160
	assert(uart_tx_shift_en == 1) else $fatal();
	
	$display("ALL TESTS PASSED SUCCESSFULLY");
	$finish();
end	

endmodule


