`timescale 1ns/1ns

module test_picmicro_midrange_core_control_flow;

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
	//$readmemb("testcontrol.prog", core.progmem.instrMemory);
	
	core.progmem.instrMemory[13'h0000] = 14'b10_1000_0010_0000; //goto 0x20
	core.progmem.instrMemory[13'h0001] = 14'b10_0000_0000_1010; //call 0x0a
	core.progmem.instrMemory[13'h0002] = 14'b11_0000_0000_0010; //movlw 0x02    
	core.progmem.instrMemory[13'h0003] = 14'b00_0000_0000_1000; //return
	core.progmem.instrMemory[13'h0004] = 14'b01_0001_0000_1011; //isr vector: bcf INTCON, T0IF
	core.progmem.instrMemory[13'h0005] = 14'b11_0000_1111_1101; //movlw 0xFD
	core.progmem.instrMemory[13'h0006] = 14'b00_0000_0000_1001; //retfie
	core.progmem.instrMemory[13'h0007] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h0008] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h0009] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h000a] = 14'b11_0000_0000_0101; //movlw 0x05
	core.progmem.instrMemory[13'h000b] = 14'b00_0000_0000_1000; //return
	core.progmem.instrMemory[13'h0009] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h000d] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h000e] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h000f] = 14'b00_0000_0000_0000; //nop
	
	core.progmem.instrMemory[13'h0010] = 14'b11_0100_1111_0001; //retlw 0xF1
	core.progmem.instrMemory[13'h0011] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h0012] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h0013] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h0014] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h0015] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h0016] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h0017] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h0018] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h0019] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h001a] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h001b] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h001c] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h001d] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h001e] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h001f] = 14'b00_0000_0000_0000; //nop
	
	core.progmem.instrMemory[13'h0020] = 14'b10_0000_0000_0001; //call 0x01   //test CALL and RETURN
	core.progmem.instrMemory[13'h0021] = 14'b10_0000_0001_0000; //call 0x10   //test CALL and RETLW
	core.progmem.instrMemory[13'h0022] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h0023] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h0029] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h002a] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h002b] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h002c] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h002d] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h0029] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h002a] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h002b] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h002c] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h002d] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h002e] = 14'b00_0000_0000_0000; //nop
	core.progmem.instrMemory[13'h002f] = 14'b00_0000_0000_0000; //nop
	
	
	
	#20 //end of reset
	assert(core.pc_out == 0) else $fatal();
	#30
	
	//execute the first command: [13'h0000] = 14'b10_1000_0010_0000; //goto 0x20
	#40
	assert(core.instr_flush == 1) else $fatal();

	//this instruction should have been flushed as we jump to 20
	#40
	assert(core.instr_current == 0) else $fatal();
	assert(core.pc_out == 13'h0020) else $fatal();

	//execute [13'h0020] = 14'b10_0000_0000_0001; //call 0x01   //test CALL and RETURN
	#40
	assert(core.instr_flush == 1) else $fatal();
	assert(core.pc_j_and_push_en == 1) else $fatal();

	//this instruction should have been flushed as we jump to 0x01
	#40
	assert(core.instr_current == 0) else $fatal();
	assert(core.pc_out == 13'h0001) else $fatal();
	assert(core.pc.hs.stack[0] ==  13'h0021) else $fatal();

	//execute [13'h0001] = 14'b10_0000_0000_1010; //call 0x0a
	#40
	assert(core.instr_flush == 1) else $fatal();
	assert(core.pc_j_and_push_en == 1) else $fatal();

	//this instruction should have been flushed as we jump to 0x0a
	#40
	assert(core.instr_current == 0) else $fatal();
	assert(core.pc_out == 13'h000a) else $fatal();
	assert(core.pc.hs.stack[1] ==  13'h0002) else $fatal();
	assert(core.pc.hs.tos == 2) else $fatal();
	assert(core.pc.hs.out == 13'h0002) else $fatal();

	//execute [13'h000a] = 14'b11_0000_0000_0101; //movlw 0x05
	#40
	assert(core.w_reg_out == 8'h05) else $fatal();

	//execute [13'h000b] = 14'b00_0000_0000_1000; //return
	#40
	assert(core.instr_flush == 1) else $fatal();
	assert(core.pc.hs.out == 13'h0002) else $fatal();
	assert(core.pc_j_by_pop_en == 1) else $fatal();

	//this instruction should have been flushed as we return to 0x02
	#40
	assert(core.instr_current == 0) else $fatal();
	assert(core.pc_out == 13'h0002) else $fatal();
	assert(core.pc.hs.stack[1] ==  13'h0002) else $fatal();
	assert(core.pc.hs.tos == 1) else $fatal();
	assert(core.pc.hs.out == 13'h0021) else $fatal();

	//execute [13'h0002] = 14'b11_0000_0000_0010; //movlw 0x02    
	#40
	assert(core.w_reg_out == 8'h02) else $fatal();

	//execute [13'h0003] = 14'b00_0000_0000_1000; //return
	#40
	assert(core.instr_flush == 1) else $fatal();
	assert(core.pc.hs.out == 13'h0021) else $fatal();
	assert(core.pc_j_by_pop_en == 1) else $fatal();

	//this instruction should have been flushed as we return to 0x21
	#40
	assert(core.instr_current == 0) else $fatal();
	assert(core.pc_out == 13'h0021) else $fatal();
	assert(core.pc.hs.tos == 0) else $fatal();
	assert(core.pc.hs.out == 13'h0000) else $fatal();

	//execute [13'h0021] = 14'b10_0000_0001_0000; //call 0x10   //test CALL and RETLW
	#40
	assert(core.instr_flush == 1) else $fatal();
	assert(core.pc_j_and_push_en == 1) else $fatal();

	//this instruction should have been flushed as we jump to 0x10
	#40
	assert(core.instr_current == 0) else $fatal();
	assert(core.pc_out == 13'h0010) else $fatal();
	assert(core.pc.hs.stack[0] ==  13'h0022) else $fatal();
	assert(core.pc.hs.tos == 1) else $fatal();
	assert(core.pc.hs.out == 13'h0022) else $fatal();

	//execute [13'h0010] = 14'b11_0100_1111_0001; //retlw 0xF1
	#40
	assert(core.w_reg_out == 8'hf1) else $fatal();
	assert(core.instr_flush == 1) else $fatal();
	assert(core.pc.hs.out == 13'h0022) else $fatal();
	assert(core.pc_j_by_pop_en == 1) else $fatal();

	//this instruction should have been flushed as we return to 0x22
	#40
	assert(core.instr_current == 0) else $fatal();
	assert(core.pc_out == 13'h0022) else $fatal();
	assert(core.pc.hs.tos == 0) else $fatal();
	assert(core.pc.hs.out == 13'h0000) else $fatal();
	assert(core.w_reg_out == 8'hf1) else $fatal();
	
	$display("ALL TESTS PASSED SUCCESSFULLY");
	$finish();
end	

endmodule
