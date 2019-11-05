`timescale 1ns/1ns

module test_picmicro_midrange_core_isr;

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

integer i;
//set the program to test
initial begin
	
	core.progmem.instrMemory[13'h0000] = 14'b10_1000_0001_0000; //reset vector: goto 0010 
	core.progmem.instrMemory[13'h0001] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h0002] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h0003] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h0004] = 14'b01_0001_0000_1011; //isr vector: bcf INTCON, T0IF
	core.progmem.instrMemory[13'h0005] = 14'b11_0000_1111_1101; //movlw 0xFD
	core.progmem.instrMemory[13'h0006] = 14'b00_0000_0000_1001; //retfie
	core.progmem.instrMemory[13'h0007] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h0008] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h0009] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h000a] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h000b] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h000c] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h000d] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h000e] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h000f] = 14'b00_0000_0000_0000; //nop
	
	core.progmem.instrMemory[13'h0010] = 14'b01_0110_1000_1011; //bsf INTCON, T0IE //enable tmr0 interrupt, t0ie is bit 5
	core.progmem.instrMemory[13'h0011] = 14'b01_0111_1000_1011; //bsf INTCON, GIE //enable interrupts, gie is bit 7
	core.progmem.instrMemory[13'h0012] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h0013] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h0014] = 14'b00_0001_1000_0001; //clrf TMR0			//reset TIMR0
	core.progmem.instrMemory[13'h0015] = 14'b01_0110_1000_0011; //bsf STATUS, RP0	//change to bank 1
	core.progmem.instrMemory[13'h0016] = 14'b01_0010_1000_0001; //bcf OPTION, T0CS //clr bit 5 of option,tmr0 should now increase by 1 for each cycle of the clock
	core.progmem.instrMemory[13'h0017] = 14'b11_0000_0000_0001; //movlw 0x01 //TMR0 should increment
	core.progmem.instrMemory[13'h0018] = 14'b10_1000_0001_0111; //goto 0017
	core.progmem.instrMemory[13'h0019] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h001a] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h001b] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h001c] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h001d] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h001e] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h001f] = 14'b00_0000_0000_0000; //nop
	
	#20 //end of reset
	assert(core.pc_out == 0) else $fatal();
	#30
	
	//execute [13'h0000] = 14'b10_1000_0001_0000; //reset vector: goto 0010 
	#40
	assert(core.instr_flush == 1) else $fatal();

	//this instruction should have been flushed as we jump to 0010
	#40
	assert(core.instr_current == 0) else $fatal();
	assert(core.pc_out == 13'h0010) else $fatal();

	//execute [13'h0010] = 14'b01_0110_1000_1011; //bsf INTCON, T0IE //enable tmr0 interrupt, t0ie is bit 5
	#40
	assert(core.intcon_t0ie == 1) else $fatal();
	
	//execute [13'h0011] = 14'b01_0111_1000_1011; //bsf INTCON, GIE //enable interrupts, gie is bit 7
	#40
	assert(core.intcon_gie == 1) else $fatal();
	
	//execute [13'h0012] = 14'b00_0000_0000_0000; //nop
	#40
	
	//execute [13'h0013] = 14'b00_0000_0000_0000; //nop
	#40
	
	//execute [13'h0014] = 14'b00_0001_1000_0001; //clrf TMR0			//reset TIMR0
	#40
	assert(core.tmr0_reg_out[5] == 0) else $fatal();
	
	//execute [13'h0015] = 14'b01_0110_1000_0011; //bsf STATUS, RP0	//change to bank 1
	#40
	assert(core.status_reg_out[5] == 1) else $fatal();
	assert(core.tmr0_reg_out == 0) else $fatal();
	
	//execute [13'h0016] = 14'b01_0010_1000_0001; //bcf OPTION, T0CS //clr bit 5 of option,tmr0 should now increase by 1 for each cycle of the clock
	#40
	assert(core.option_reg_out[5] == 0) else $fatal();
	assert(core.tmr0_reg_out == 0) else $fatal();

	i = 1;
	do begin
		//execute [13'h0017] = 14'b11_0000_0000_0001; //movlw 0x01 //TMR0 should increment
		#40
		assert(core.w_reg_out == 8'h01) else $fatal();
		assert(core.tmr0_reg_out == i % 256) else $fatal();
		if(i == 256)
			break;
		i = i + 1;
		
		//execute [13'h0018] = 14'b10_1000_0001_0111; //goto 0017 //TMR0 should increment
		#40
		assert(core.instr_flush == 1) else $fatal();
		assert(core.tmr0_reg_out == i % 256) else $fatal();
		if(i == 256)
			break;
		i = i + 1;
		
		//this instruction should have been flushed as we jump to 0017 //TMR0 should increment
		#40
		assert(core.instr_current == 0) else $fatal();
		assert(core.pc_out == 13'h0017) else $fatal();
		assert(core.tmr0_reg_out == i % 256) else $fatal();
		if(i == 256)
			break;
		i = i + 1;
	end while (1);
	
	assert(core.intcon_t0if_set_en == 1) else $fatal(); //we overflowed during the mov, we're going to now execute the next instruction
	assert(core.tmr0_reg_out == 0) else $fatal(); //we overflowed so the new count should be zero
	#10
	assert(core.intcon_t0if == 1) else $fatal(); //as of the first cycle of the next instruction, we should be interrupting because tmr0!
	assert(core.interrupt_flag == 1) else $fatal(); //yeah, we should be interrupting!
	
	//finish executing [13'h0018] = 14'b10_1000_0001_0111; //goto 0017 //TMR0 should increment
	//now, because we are trying to interrupt a GOTO, the interrupt is delayed by an additional cycle (otherwise we would have jumped here)
	#30
	assert(core.tmr0_reg_out == 1) else $fatal();
	assert(core.instr_flush == 1) else $fatal();
	assert(core.interrupt_flag == 1) else $fatal(); //we are still trying to interrupt!
	assert(core.pc_j_to_isr == 0) else $fatal(); //but no jump here, because GOTO is a two-cycle instruction!
	
	//this instruction would normally be a NOP that takes us to 0017 (i.e. there wouldn't be a flush), but now it's an ISR nop that prepares the jump to 0004. //TMR0 should increment
	#40
	assert(core.tmr0_reg_out == 2) else $fatal();
	assert(core.pc_out == 13'h0017) else $fatal();
	assert(core.instr_flush == 1) else $fatal();
	assert(core.pc_j_to_isr == 1) else $fatal();
	
	#40
	//this instruction is an ISR nop that loads 0004. TOS should be set to 0017 //TMR0 should increment
	assert(core.tmr0_reg_out == 3) else $fatal();
	assert(core.pc_out == 13'h0004) else $fatal();
	assert(core.pc.hs.stack[0] ==  13'h0017) else $fatal();
	assert(core.pc.hs.tos == 1) else $fatal();
	assert(core.pc.hs.out == 13'h0017) else $fatal();
	assert(core.interrupt_flag == 0) else $fatal(); //we should no longer be trying to interrupt...
	assert(core.intcon_gie == 0) else $fatal(); //...because gie should now be disabled :-)
	
	//we're now at the ISR
	//execute [13'h0004] = 14'b01_0001_0000_1011; //isr vector: bcf INTCON, T0IF
	#40
	assert(core.tmr0_reg_out == 4) else $fatal();
	assert(core.intcon_t0if == 0) else $fatal(); 
	
	//execute [13'h0005] = 14'b11_0000_1111_1101; //movlw 0xFD
	#40
	assert(core.tmr0_reg_out == 5) else $fatal();
	assert(core.w_reg_out == 8'hfd) else $fatal();
	
	//execute [13'h0006] = 14'b00_0000_0000_1001; //retfie
	#40
	assert(core.tmr0_reg_out == 6) else $fatal();
	assert(core.instr_flush == 1) else $fatal();
	assert(core.pc.hs.out == 13'h0017) else $fatal();
	assert(core.pc_j_by_pop_en == 1) else $fatal();
	assert(core.intcon_gie_set_en == 1) else $fatal(); //we should be reenabling interrupts

	#10
	assert(core.intcon_gie == 1) else $fatal(); //we should have reenabled interrupts
	//finish executing this instruction which should have been flushed as we return to 0017
	#30
	assert(core.tmr0_reg_out == 7) else $fatal();
	assert(core.instr_current == 0) else $fatal();
	assert(core.pc_out == 13'h0017) else $fatal();
	assert(core.pc.hs.tos == 0) else $fatal();
	
	//execute [13'h0017] = 14'b11_0000_0000_0001; //movlw 0x01 //TMR0 should increment
	#40
	assert(core.tmr0_reg_out == 8) else $fatal();
	assert(core.w_reg_out == 8'h01) else $fatal();
		
	$display("ALL TESTS PASSED SUCCESSFULLY");
	$finish();
	/*
	//after 40*250 we should overflow
	
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
	*/
	
	$display("ALL TESTS PASSED SUCCESSFULLY");
	$finish();
end	

endmodule
