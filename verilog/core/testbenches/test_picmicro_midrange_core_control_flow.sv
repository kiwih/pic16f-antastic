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
	$readmemb("testcontrol.prog", core.progmem.instrMemory);
	#20 //end of reset
	assert(core.pc_out == 0) else $fatal();
	#30
	
	//execute the first command: 10100001010000 //00.    goto 0x50
	#40
	assert(core.instr_flush == 1) else $fatal();

	//this instruction should have been flushed as we jump to 50
	#40
	assert(core.instr_current == 0) else $fatal();
	assert(core.pc_out == 13'h0050) else $fatal();

	//execute 10000000000001 //50.    call 0x01
	#40
	assert(core.instr_flush == 1) else $fatal();
	assert(core.pc_j_and_push_en == 1) else $fatal();

	//this instruction should have been flushed as we jump to 0x01
	#40
	assert(core.instr_current == 0) else $fatal();
	assert(core.pc_out == 13'h0001) else $fatal();
	assert(core.pc.hs.stack[0] ==  13'h0051) else $fatal();

	//execute 10000000000101 //01.    call 0x05 
	#40
	assert(core.instr_flush == 1) else $fatal();
	assert(core.pc_j_and_push_en == 1) else $fatal();

	//this instruction should have been flushed as we jump to 0x05
	#40
	assert(core.instr_current == 0) else $fatal();
	assert(core.pc_out == 13'h0005) else $fatal();
	assert(core.pc.hs.stack[1] ==  13'h0002) else $fatal();
	assert(core.pc.hs.tos == 2) else $fatal();
	assert(core.pc.hs.out == 13'h0002) else $fatal();

	//execute 11000000000101 //05.    movlw 0x05    
	#40
	assert(core.w_reg_out == 8'h05) else $fatal();

	//execute 00000000001000 //06.    return
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
	assert(core.pc.hs.out == 13'h0051) else $fatal();

	//execute 11000000000010 //02.    movlw 0x02   
	#40
	assert(core.w_reg_out == 8'h02) else $fatal();

	//execute 00000000001000 //03.    return
	#40
	assert(core.instr_flush == 1) else $fatal();
	assert(core.pc.hs.out == 13'h0051) else $fatal();
	assert(core.pc_j_by_pop_en == 1) else $fatal();

	//this instruction should have been flushed as we return to 0x51
	#40
	assert(core.instr_current == 0) else $fatal();
	assert(core.pc_out == 13'h0051) else $fatal();
	assert(core.pc.hs.tos == 0) else $fatal();
	assert(core.pc.hs.out == 13'h0000) else $fatal();

	//execute 10000000000100 //51.    call 0x04
	#40
	assert(core.instr_flush == 1) else $fatal();
	assert(core.pc_j_and_push_en == 1) else $fatal();

	//this instruction should have been flushed as we jump to 0x04
	#40
	assert(core.instr_current == 0) else $fatal();
	assert(core.pc_out == 13'h0004) else $fatal();
	assert(core.pc.hs.stack[0] ==  13'h0052) else $fatal();
	assert(core.pc.hs.tos == 1) else $fatal();
	assert(core.pc.hs.out == 13'h0052) else $fatal();

	//execute 11010011110001 //04.    retlw 0xF1
	#40
	assert(core.w_reg_out == 8'hf1) else $fatal();
	assert(core.instr_flush == 1) else $fatal();
	assert(core.pc.hs.out == 13'h0052) else $fatal();
	assert(core.pc_j_by_pop_en == 1) else $fatal();

	//this instruction should have been flushed as we return to 0x52
	#40
	assert(core.instr_current == 0) else $fatal();
	assert(core.pc_out == 13'h0052) else $fatal();
	assert(core.pc.hs.tos == 0) else $fatal();
	assert(core.pc.hs.out == 13'h0000) else $fatal();
	assert(core.w_reg_out == 8'hf1) else $fatal();
	
	$display("ALL TESTS PASSED SUCCESSFULLY");
	$finish();
end	

endmodule
