`timescale 1ns/1ns

module test_picmicro_midrange_core_tmr0;

reg clk, clk_wdt, rst_ext;

initial begin: CLOCK_GENERATOR
	clk = 0;
	clk_wdt = 0;
	forever begin 
		#5 clk = ~clk; //every 5ns invert the clock, so clock period is 10ns = 100MHz
	end
end

initial begin: EXT_RST_GENERATOR
	rst_ext = 1;
	#20 rst_ext = 0; //after 20ns clear the reset
end

picmicro_midrange_core core(
	.clk(clk),
	.clk_wdt(clk_wdt),
	.rst_ext(rst_ext),
	
	.extern_peripherals_data_out(8'd0)
);

//set the program to test
initial begin
	$readmemb("test_tmr0.prog", core.progmem.instrMemory);
	#20 //end of reset
	assert(core.pc_out == 0) else $fatal();
	#30
	
	//execute 00000110000001 //00.    clrf TMR0 //reset TMR0, tmr0 should not increment
	#40
	assert(core.tmr0_reg_out[5] == 0) else $fatal();

	//execute 01011010000011 //01.    bsf STATUS, RP0     change to bank 1
	#40
	assert(core.status_reg_out[5] == 1) else $fatal();
	assert(core.tmr0_reg_out == 0) else $fatal();

	//execute 01001010000001 //02.    bcf OPTION, T0CS    clr bit 5 of OPTION
	#40
	assert(core.option_reg_out[5] == 0) else $fatal();
	assert(core.tmr0_reg_out == 0) else $fatal();

	//execute 00000000000000 //03.    nop //tmr0 should increment
	#40
	assert(core.tmr0_reg_out == 1) else $fatal();

	//execute 00000000000000 //04.    nop //tmr0 should increment
	#40
	assert(core.tmr0_reg_out == 2) else $fatal();

	//execute 00000000000000 //05.    nop       //TMR0 should increase by 1 for each cycle of the clock
	#40
	assert(core.tmr0_reg_out == 3) else $fatal();

	//execute 01000000000001 //06.    bcf OPTION, PS0 //clear the prescaler select bits, setting it to div/2  
	#40
	assert(core.tmr0_reg_out == 4) else $fatal();

	//execute 01000010000001 //07.    bcf OPTION, PS1   
	#40
	assert(core.tmr0_reg_out == 5) else $fatal();

	//execute 01000100000001 //08.    bcf OPTION, PS2    
	#40
	assert(core.tmr0_reg_out == 6) else $fatal();

	//execute 01000110000001 //09.    bcf OPTION, PSA    clr bit 3 of OPTION, enabling the prescaler 
	#40
	assert(core.tmr0_reg_out == 7) else $fatal();

	//execute 00000000000000 //0A.    nop       //now the timer should increase every second instruction
	#40
	assert(core.tmr0_reg_out == 8) else $fatal();

	//execute 00000000000000 //0B.    nop       
	#40
	assert(core.tmr0_reg_out == 8) else $fatal();

	//execute 01010000000001 //0C.    bsf OPTION, PS0 //set the prescaler PS0, setting it to div/4 . However, it will be only 3 cycles to the next increment due to current value of prescaler
	#40
	assert(core.tmr0_reg_out == 9) else $fatal();

	//execute 00000000000000 //0D.    nop       
	#40
	assert(core.tmr0_reg_out == 9) else $fatal();

	//execute 00000000000000 //0E.    nop       
	#40
	assert(core.tmr0_reg_out == 9) else $fatal();

	//execute 00000000000000 //0F.    nop       
	#40
	assert(core.tmr0_reg_out == 10) else $fatal();

	//execute 00000000000000 //10.    nop       
	#40
	assert(core.tmr0_reg_out == 10) else $fatal();

	//execute 00000000000000 //11.    nop       
	#40
	assert(core.tmr0_reg_out == 10) else $fatal();

	//execute 00000000000000 //12.    nop       
	#40
	assert(core.tmr0_reg_out == 10) else $fatal();

	//execute 01010110000001 //13.    bsf OPTION, PSA    clr bit 3 of OPTION, disabling the prescaler
	#40


	//execute 01001010000011 //14.    bcf STATUS, RP0    change to bank 0
	#40


	//execute 11000011111101 //15.    movlw 0xFD
	#40


	//execute 00000010000001 //16.    movwf TMR0 //tmr0 should not increment
	#40
	assert(core.tmr0_reg_out == 8'hfd) else $fatal();

	//execute 00000000000000 //17.    nop //tmr0 should not increment
	#40
	assert(core.tmr0_reg_out == 8'hfd) else $fatal();

	//execute 00000000000000 //18.    nop //tmr0 should not increment
	#40
	assert(core.tmr0_reg_out == 8'hfd) else $fatal();

	//execute 00000000000000 //19.    nop //tmr0 should increment
	#40
	assert(core.tmr0_reg_out == 8'hfe) else $fatal();

	//execute 00000000000000 //1A.    nop //tmr0 should increment
	#40
	assert(core.tmr0_reg_out == 8'hff) else $fatal();
	assert(core.tmr0if_set_en == 0) else $fatal();

	//execute 00000000000000 //1B.    nop //tmr0 should overflow
	#40
	assert(core.tmr0_reg_out == 8'h00) else $fatal();
	assert(core.tmr0if_set_en == 1) else $fatal();
	
	
	$display("ALL TESTS PASSED SUCCESSFULLY");
	$finish();
end	

endmodule
