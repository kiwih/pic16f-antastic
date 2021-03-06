`timescale 1ns/1ns

module test_picmicro_midrange_core_basic_instructions;

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
	$readmemb("test.prog", core.progmem.instrMemory);
	#20 //end of reset
	assert(core.pc_out == 0) else $fatal();
	assert(core.control.q_count == 0) else $fatal();
	#10
	assert(core.control.q_count == 1) else $fatal();
	#10
	assert(core.control.q_count == 2) else $fatal();
	#10
	assert(core.control.q_count == 3) else $fatal();
	
	//begin the command at address 0, which is a nop
	#10
	assert(core.control.q_count == 0) else $fatal();
	assert(core.instr_current == 14'b00000000000000) else $fatal();
	#30 //finish the nop
	
	//#execute the command at address 1, which is 11000010101011 //movlw 0xAB	W <= 0xAB
	#40
	assert(core.w_reg_out == 8'hab) else $fatal();
	
	//execute the command at address 2, which is 00000010100000 //movwf 0x20	mem[0x20] <= W = 0xAB
	#40
	assert(core.regfile.gpRegistersA[0] == 8'hab) else $fatal();

	//execute the command at address 3, which is 11000011001101 //movlw 0xCD	W <= 0xCD
	#40
	assert(core.w_reg_out == 8'hcd) else $fatal();

	//execute the command at address 4, which is 00000010100001 //movwf 0x21	mem[0x21] <= W = 0xCD
	#40
	assert(core.regfile.gpRegistersA[1] == 8'hcd) else $fatal();
	assert(core.status_c == 0) else $fatal();  //ensure we have c=0 before the next command
   

	//address 5, which is 00011100100000 //addwf 0 0x20	W <= W + mem[0x20] = 0xAB + 0xCD = Carry and 0x78 and DC and !Z
	#40
	assert(core.w_reg_out == 8'h78) else $fatal();
	assert(core.status_c == 1) else $fatal();
	assert(core.status_dc == 1) else $fatal();
	assert(core.status_z == 0) else $fatal();

	//address 6, which is 00100000100000 //6.	movfw 1 0x20	W <= mem[0x20] = 0xAB
	#40
	assert(core.w_reg_out == 8'hab) else $fatal();

	//address 7, which is 00010100100001 //7.	andwf 0 0x21	W <= W & mem[0x21] = 0xAB & 0xCD = 0x89
	#40
	assert(core.w_reg_out == 8'h89) else $fatal();
	assert(core.status_z == 0) else $fatal(); //ensure we have z=0 before the next command

	//address 8, which is 00000110100001 //8.	clrf 0x21	mem[0x21] <= 0x00 and Z = 1
	#40
	assert(core.regfile.gpRegistersA[1] == 8'h00) else $fatal();
	assert(core.status_z == 1) else $fatal(); //clr commands should set z = 1

	//address 9, which is 00000110100010 //9.	clrf 0x22	mem[0x22] <= 0x00 and Z = 1
	#40
	assert(core.regfile.gpRegistersA[2] == 8'h00) else $fatal();
	assert(core.status_z == 1) else $fatal(); //clr commands should set z = 1

	//address 10, which is 00010100100000 //10.	andwf 0 0x20	W <= W & mem[0x20] = 0x89 & 0xAB = 0x89 and !Z
	#40
	assert(core.w_reg_out == 8'h89) else $fatal();
	assert(core.status_z == 0)  else $fatal();
	assert(core.regfile.gpRegistersA[0] == 8'hab) else $fatal(); //check that mem[0x20] is still 0xab before next command

	//address 11, which is 00010110100000 //11.	andwf 1 0x20	mem[0x20] <= W & mem[0x20] = 0x89 & 0xAB = 0x89 and !Z
	#40
	assert(core.regfile.gpRegistersA[0] == 8'h89) else $fatal();
	assert(core.status_z == 0) else $fatal();

	//address 12, which is 00010100100010 //12.	andwf 0 0x22	W <= W & mem[0x22] = 0x89 & 0x00 = 0x00 and Z 
	#40
	assert(core.w_reg_out == 8'h00) else $fatal();
	assert(core.status_z == 1) else $fatal();

	//address 13, which is 00000110000011 //13.	clrf STATUS	STATUS <= 0x00 and Z (since the clrf sets the Z) = 0x1c (the power bits are still set)
	#40
	assert(core.status_reg_out[2:0] == 3'b100) else $fatal();

	//address 14, which is 00100000100000 //14.	movfw 0 STATUS	W <= STATUS = 0x04 and !Z
	#40
	assert(core.w_reg_out == 8'h1c) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b000) else $fatal();

	//address 15, which is 00000100000000 //15.	clrw		W <= 0x00 and Z
	#40
	assert(core.w_reg_out == 8'h00) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b100) else $fatal();

	//address 16, which is 00100110100000 //16.	comf 1 0x20	mem[0x20] <= ~mem[0x20] = 0x76
	#40
	assert(core.regfile.gpRegistersA[0] == 8'h76) else $fatal();

	//address 17, which is 00100100100001 //17.	comf 0 0x21	W <= ~mem[0x21] = 0xFF
	#40
	assert(core.w_reg_out == 8'hff) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b000) else $fatal();

	//address 18, which is 00100110100001 //18.	comf 1 0x21	mem[0x21] <= ~mem[0x21] = 0xFF
	#40
	assert(core.regfile.gpRegistersA[1] == 8'hff) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b000) else $fatal();

	//address 19, which is 00101010100000 //19.	incf 1 0x20	mem[0x20] <= mem[0x20] + 1 = 0x76 + 1 = 0x77
	#40
	assert(core.regfile.gpRegistersA[0] == 8'h77) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b000) else $fatal();

	//address 20, which is 00101000100001 //20.	incf 0 0x21	W <= mem[0x21] + 1 = 0xFF + 1 = 0x00 and Z
	#40
	assert(core.w_reg_out == 8'h00) else $fatal();
	assert(core.regfile.gpRegistersA[1] == 8'hff) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b100) else $fatal();

	//address 21, which is 11000000000001 //21.	movlw 0x01	W <= 0x01
	#40
	assert(core.w_reg_out == 8'h01) else $fatal();

	//address 22, which is 00000010100010 //22.	movwf 0x22	mem[0x22] <= W = 0x01
	#40
	assert(core.regfile.gpRegistersA[2] == 8'h01) else $fatal();

	//address 23, which is 00001110100000 //23.	decf 1 0x20	mem[0x20] <= mem[0x20] - 1 = 0x77 - 1 = 0x76
	#40
	assert(core.regfile.gpRegistersA[0] == 8'h76) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b000) else $fatal();

	//address 24, which is 00001100100010 //24.	decf 0 0x22	W <= mem[0x22] - 1 = 0x01 - 1 = 0x00 and Z
	#40
	assert(core.w_reg_out == 8'h00) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b100) else $fatal();

	//address 25, which is 00010000100000 //25.	iorwf 0 0x20	W <= W | mem[0x20] = 0x00 | 0x76 = 0x76
	#40
	assert(core.w_reg_out == 8'h76) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b000) else $fatal();

	//address 26, which is 00010000100010 //26.	iorwf 0 0x21	W <= W | mem[0x22] = 0x76 | 0x01 = 0x77
	#40
	assert(core.w_reg_out == 8'h77) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b000) else $fatal();

	// # # # #  # # # # # # # //test decfsz # # # # # # # # # # #

	//address 27, which is 00010010100000 //27.	iorwf 1 0x20	mem[0x20] <= W | mem[0x20] = 0x77 | 0x76 = 0x77
	#40
	assert(core.regfile.gpRegistersA[0] == 8'h77) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b000) else $fatal();

	//address 28, which is 00101110100000 //28.	decfsz 1 0x20	mem[0x20] <= mem[0x20] - 1 SZ = 0x77 - 1 SZ = 0x76, !Z, NO SKIP
	#40
	assert(core.regfile.gpRegistersA[0] == 8'h76) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b000) else $fatal();
	assert(core.instr_flush == 0) else $fatal();

	//address 29, which is 11000010101011 //29.	movlw 0xAB	W <= 0xAB
	#40
	assert(core.w_reg_out == 8'hab) else $fatal();

	//address 30, which is 00101100100010 //30.	decfsz 0 0x22	W <= mem[0x22] - 1 SZ = 0x01 - 1 SZ = 0x00 Z, SKIP
	#40
	assert(core.w_reg_out == 8'h00) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b100) else $fatal();
	assert(core.instr_flush == 1) else $fatal();

	//address 31, which is 11000010101011 //31.	movlw 0xAB	SKIPPED W <= 0xAB
	#40
	assert(core.instr_current == 0) else $fatal();
	assert(core.w_reg_out == 8'h00) else $fatal();

	//address 32, which is 00101110100010 //32.	decfsz 0 0x22	mem[0x22] <= mem[0x22] - 1 SZ = 0x01 - 1 SZ = 0x00 Z, SKIP
	#40
	assert(core.regfile.gpRegistersA[2] == 8'h00) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b100) else $fatal();
	assert(core.instr_flush == 1) else $fatal();

	//address 33, which is 11000010101011 //33.	movlw 0xAB	SKIPPED W <= 0xAB
	#40
	assert(core.instr_current == 0) else $fatal();
	assert(core.w_reg_out == 8'h00) else $fatal();

	//address 34, which is 00101110100000 //34.	decfsz 1 0x20	mem[0x20] <= mem[0x20] - 1 SZ = 0x76 - 1 SZ = 0x75, !Z, NO SKIP
	#40
	assert(core.regfile.gpRegistersA[0] == 8'h75) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b000) else $fatal();
	assert(core.instr_flush == 0) else $fatal();

	//address 35, which is 11000011001101 //35.	movlw 0xCD	W <= 0xCD
	#40
	assert(core.w_reg_out == 8'hcd) else $fatal();
	
	//# # # #  # # # # # # # //test incfsz # # # # # # # # # # #

	//address 36, which is 00111100100000 //36.    incfsz 0 0x20       W <= mem[0x20] + 1 SZ = 0x75 + 1 SZ = 0x76, !Z, NO SKIP
	#40
	assert(core.w_reg_out == 8'h76) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b000) else $fatal();
	assert(core.instr_flush == 0) else $fatal();

	//address 37, which is 11000011111111 //37.    movlw 0xFF          W <= 0xFF
	#40
	assert(core.w_reg_out == 8'hff) else $fatal();

	//address 38, which is 00000010110000 //38.    movwf 0x30          mem[0x30] <= W = 0xFF
	#40
	assert(core.regfile.gpRegistersA[16] == 8'hff) else $fatal();

	//address 39, which is 00111100110000 //39.    incfsz 0 0x30       W <= mem[0x30] + 1 SZ = 0xFF + 1 SZ = 0x00, Z, SKIP
	#40
	assert(core.w_reg_out == 8'h00) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b100) else $fatal();
	assert(core.instr_flush == 1) else $fatal();

	//address 40, which is 11000010101011 //40.    movlw 0xAB          SKIPPED W <= 0xAB
	#40
	assert(core.instr_current == 0) else $fatal();
	assert(core.w_reg_out == 8'h00) else $fatal();

	//address 41, which is 00111110110000 //41.    incfsz 1 0x30       mem[0x30] <= mem[0x30] + 1 SZ = 0xFF + 1 SZ = 0x00, Z, SKIP
	#40
	assert(core.regfile.gpRegistersA[16] == 8'h00) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b100) else $fatal();
	assert(core.instr_flush == 1) else $fatal();

	//address 42, which is 11000010101011 //42.    movlw 0xAB          SKIPPED W <= 0xAB
	#40
	assert(core.instr_current == 0) else $fatal();
	assert(core.w_reg_out == 8'h00) else $fatal();

	//address 43, which is 00111110110000 //43.    incfsz 1 0x30       mem[0x30] <= mem[0x30] + 1 SZ = 0x00 + 1 SZ = 0x01, Z, NO SKIP
	#40
	assert(core.regfile.gpRegistersA[16] == 8'h01) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b000) else $fatal();
	assert(core.instr_flush == 0) else $fatal();

	//address 44, which is 11000010101011 //44.    movlw 0xAB          W <= 0xAB
	#40
	assert(core.w_reg_out == 8'hab) else $fatal();

	// # # # #  # # # # # # # rlf # # # # # # # # # # # # #

	//address 45, which is 00000010100010 //45.    movwf 0x22          mem[0x22] <= W = 0xAB
	#40
	assert(core.regfile.gpRegistersA[2] == 8'hab) else $fatal();

	//address 46, which is 00110110100010 //46.    rlf 1 0x22          mem[0x22] <= mem[0x22] << 1 = 0x56 and C (Z not affected)
	#40
	assert(core.regfile.gpRegistersA[2] == 8'h56) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b001) else $fatal();

	//address 47, which is 00110100100010 //47.    rlf 0 0x22          W <= mem[0x22] << 1 = 0xAD and !C (Z not affected)
	#40
	assert(core.w_reg_out == 8'had) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b000) else $fatal();

	// # # # #  # # # # # # # rrf # # # # # # # # # # # # #

	//address 48, which is 11000010101011 //48.    movlw 0xAB          W <= 0xAB
	#40
	assert(core.w_reg_out == 8'hab) else $fatal();

	//address 49, which is 00000010100010 //49.    movwf 0x22          mem[0x22] <= W = 0xAB
	#40
	assert(core.regfile.gpRegistersA[2] == 8'hab) else $fatal();

	//address 50, which is 00110010100010 //50.    rrf 1 0x22          mem[0x22] <= mem[0x22] << 1 = 0x55 and C (Z not affected)
	#40
	assert(core.regfile.gpRegistersA[2] == 8'h55) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b001) else $fatal();

	//address 51, which is 00110010100010 //51.    rrf 1 0x22          mem[0x22] <= mem[0x22] << 1 = 0xAA and C (Z not affected)
	#40
	assert(core.regfile.gpRegistersA[2] == 8'haa) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b001) else $fatal();

	//address 52, which is 00110000100010 //52.    rrf 0 0x22          W <= mem[0x22] << 1 = 0xd5 and !C (Z not affected)
	#40
	assert(core.w_reg_out == 8'hd5) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b000) else $fatal();

	// # # # #  # # # # # # # subwf # # # # # # # # # # # # #

	//address 53a, which is 11000000101010 //53a.   movlw 0x2A          W <= 0x2A
	#40
	assert(core.w_reg_out == 8'h2a) else $fatal();

	//address 53b, which is 00000010100010 //53b.   movwf 0x22          mem[0x22] <= W = 0x2A
	#40
	assert(core.regfile.gpRegistersA[2] == 8'h2a) else $fatal();

	//address 53c, which is 11000000010101 //53c.    movlw 0x15          W <= 0x15
	#40
	assert(core.w_reg_out == 8'h15) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b000) else $fatal();

	//address 54, which is 00001010100010 //54.    subwf 1 0x22        mem[0x22] <= mem[0x22] - W = 0x2A - 0x15 = 0x15 !Z C DC 
	#40
	assert(core.regfile.gpRegistersA[2] == 8'h15) else $fatal();
	assert(core.status_z == 0) else $fatal();
	assert(core.status_c == 1) else $fatal();
	assert(core.status_dc == 1) else $fatal();

	//address 55, which is 00001000100010 //55.    subwf 0 0x22        W         <= mem[0x22] - W = 0x15 - 0x15 = 0x0 Z C DC
	#40
	assert(core.w_reg_out == 8'h00) else $fatal();
	assert(core.status_z == 1) else $fatal();
	assert(core.status_c == 1) else $fatal();
	assert(core.status_dc == 1) else $fatal();

	//address 56, which is 11000010101011 //44.    movlw 0xAB          W <= 0xAB
	#40
	assert(core.w_reg_out == 8'hab) else $fatal(); 

	//address 57, which is 00001010100010 //57.    subwf 1 0x22        mem[0x22] <= mem[0x22] - W = 0x15 - 0xAB = 0x6a !Z !C !DC
	#40
	assert(core.regfile.gpRegistersA[2] == 8'h6a) else $fatal();
	assert(core.status_z == 0) else $fatal();
	assert(core.status_c == 0) else $fatal();
	assert(core.status_dc == 0) else $fatal();

	// # # # #  # # # # # swapf # # # # # # # # # # #

	//test 60, 11000010101011 //60.    movlw 0xAB          W         <= 0xAB
	#40
	assert(core.w_reg_out == 8'hab) else $fatal();

	//test 61, which is 00000010100000 //61.    movwf 0x20          mem[0x20] <= W = 0xAB
	#40
	assert(core.regfile.gpRegistersA[0] == 8'hab) else $fatal();

	//test 62, which is 00111000100000 //62.    swapf 0 0x20        W         <= swap(mem[0x20) = swap(0xAB) = 0xBA
	#40
	assert(core.w_reg_out == 8'hba) else $fatal();

	//test 63, which is 00111010100000 //63.    swapf 1 0x20        mem[0x20] <= swap(mem[0x20) = swap(0xAB) = 0xBA
	#40
	assert(core.regfile.gpRegistersA[0] == 8'hba) else $fatal();

	// # # # #  # # # # # # xorwf # # # # # # # # # # # #

	//test 70, 11000010101011 //70.    movlw 0xAB          W         <= 0xAB
	#40
	assert(core.w_reg_out == 8'hab) else $fatal();

	//test 71, 00000010100000 //71.    movwf 0x20          mem[0x20] <= W = 0xAB
	#40
	assert(core.regfile.gpRegistersA[0] == 8'hab) else $fatal();

	//test 72, 11000010100101 //72.    movlw 0xA5          W         <= 0xA5
	#40
	assert(core.w_reg_out == 8'ha5) else $fatal();

	//test 73, 00011010100000 //73.    xorwf 0 0x20        mem[0x20] <= mem[0x20] ^ W = 0xAB ^ 0xA5 = 0x0E, !Z
	#40
	assert(core.regfile.gpRegistersA[0] == 8'h0e) else $fatal();
	assert(core.status_z == 0) else $fatal();

	//test 74, 11000000001110 //74.    movlw 0x0E          W         <= 0x0E
	#40
	assert(core.w_reg_out == 8'h0e) else $fatal();

	//test 75, 00011000100000 //75.    xorwf 1 0x20        mem[0x20] <= mem[0x20] ^ W = 0xA5 ^ 0xA5 = 0x00, Z
	#40
	assert(core.w_reg_out == 8'h00) else $fatal();
	assert(core.status_z == 1) else $fatal();

	// # # # #  # # # # # # # test DC bit # # # # # # # # # # # #

	//test 80, 11000000101000 //80.    movlw 0x28          W         <= 0x28
	#40
	assert(core.w_reg_out == 8'h28) else $fatal();

	//test 81, 00000010100000 //81.    movwf 0x20          mem[0x20] <= W = 0x28
	#40
	assert(core.regfile.gpRegistersA[0] == 8'h28) else $fatal();

	//test 82, 11000000011000 //82.    movlw 0x18          W         <= 0x18
	#40
	assert(core.w_reg_out == 8'h18) else $fatal();

	//test 83, 00011100100000 //83.    addwf 0 0x20        W         <= W + mem[0x20] = 0x28 + 0x18 = 0x40, !C, !Z, DC
	#40
	assert(core.w_reg_out == 8'h40) else $fatal();
	assert(core.status_reg_out[2:0] ==3'b010) else $fatal();

	// # # # #  # # # # # # test DC bit with subtraction # # # # # # # # # # # 

	//test 90, 11000001000000 //90.    movlw 0x40          W         <= 0x40
	#40
	assert(core.w_reg_out == 8'h40) else $fatal();

	//test 91, 00000010100000 //91.    movwf 0x20          mem[0x20] <= W = 0x40
	#40
	assert(core.regfile.gpRegistersA[0] == 8'h40) else $fatal();

	//test 92, 11000000101000 //92.    movlw 0x28          W         <= 0x28
	#40
	assert(core.w_reg_out == 8'h28) else $fatal();

	//test 93, 00001000100000 //93.    SUBwf 0 0x20        W         <= mem[0x20] - W = 0x40 - 0x28 = 0x18, C, !Z, !DC
	#40
	assert(core.w_reg_out == 8'h18) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b001) else $fatal();

	// # # # #  # # # # # # # # bcf / bsf # # # # # # # # 3 # # 3 # # # #

	//test 100, 11000010101011 //100.   movlw 0xAB          W         <= 0xAB
	#40
	assert(core.w_reg_out == 8'hab) else $fatal();

	//test 101, 00000010100000 //101.   movwf 0x20          mem[0x20] <= W = 0xAB
	#40
	assert(core.regfile.gpRegistersA[0] == 8'hab) else $fatal();

	//test 102,3'b01001110100000 //102.   bcf 7 0x20          mem[0x20] <= clr bit 7 of mem[0x20] = 0xAB clr bit 7 = 0x2B
	#40
	assert(core.regfile.gpRegistersA[0] == 8'h2b) else $fatal();

	//test 103,3'b01010100100000 //103.   bsf 2 0x20          mem[0x20] <= set bit 2 of mem[0x20] = 0x2B set bit 2 = 0x2F
	#40
	assert(core.regfile.gpRegistersA[0] == 8'h2f) else $fatal();

	//test 104, 01100000100000 //104.   btfsc 0 0x20        skip next if bit 0 is 0 in mem[0x20], which is 0x2F, so no skip
	#40
	assert(core.instr_flush == 0) else $fatal();

	//test 105, 01101000100000 //105.   btfsc 4 0x20        skip next if bit 4 is 0 in mem[0x20], which is 0x2F, so skip
	#40
	assert(core.instr_flush == 1) else $fatal();

	//test 106, 11000010101011 //106.   movlw 0xAB          SKIPPED W <= 0xAB
	#40
	assert(core.instr_current == 0) else $fatal();

	//test 107, 01111000100000 //107.   btfsc 0 0x20        skip next if bit 4 is 1 in mem[0x20], which is 0x2F, so no skip
	#40
	assert(core.instr_flush == 0) else $fatal();

	//test 108, 01110000100000 //108.   btfsc 4 0x20        skip next if bit 0 is 1 in mem[0x20], which is 0x2F, so skip
	#40
	assert(core.instr_flush == 1) else $fatal();

	//test 106, 11000010101011 //109.   movlw 0xAB          SKIPPED W <= 0xAB
	#40
	assert(core.instr_current == 0) else $fatal();

	// # # # #  # # # # # # # ADDLW # # # # # # # # # # # #

	//test 120, 11000010101011 //120.   movlw 0xAB          W         <= 0xAB
	#40
	assert(core.w_reg_out == 8'hab) else $fatal();

	//test 121, 11111000001011 //121.   addlw 0x0B          W         <= 0xAB + 0x0B = 0xB6, !Z, !C, DC
	#40
	assert(core.w_reg_out == 8'hb6) else $fatal();
	assert(core.status_reg_out[2:0] ==3'b010) else $fatal();

	//test 122, 11111001001010 //122.   addlw 0x4A           W         <= 0xB6 + 0x4A = 0x00, Z, C, DC
	#40
	assert(core.w_reg_out == 8'h00) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b111) else $fatal();

	// # # # #  # # # # # # # # ANDLW # # # # # # # # # # # # # # # # #

	//test 130, 11000010101011 //130.   movlw 0xAB          W         <= 0xAB
	#40
	assert(core.w_reg_out == 8'hab) else $fatal();

	//test 131, 111100100000001 //131.   andlw 0x01          W         <= 0xAB & 0x01 = 0x01 and !Z
	#40
	assert(core.w_reg_out == 8'h01) else $fatal();
	assert(core.status_z == 0) else $fatal();

	//test 132, 11100100010000 //132.   andlw 0x10          W         <= 0x01 & 0x10 = 0x00 and Z
	#40
	assert(core.w_reg_out == 8'h00) else $fatal();
	assert(core.status_z == 1) else $fatal();

	// # # # #  # # # # # # # # IORLW # # # # # # # # # # # # # # # # #

	//test 140, 11000010101011 //140.   movlw 0xAB          W         <= 0xAB
	#40
	assert(core.w_reg_out == 8'hab) else $fatal();

	//test 141, 11100100000100 //141.   iorlw 0x01          W         <= 0xAB | 0x04 = 0xAF and !Z
	#40
	assert(core.w_reg_out == 8'haf) else $fatal();
	assert(core.status_z == 0) else $fatal();

	//test 142, 11000000000000 //142.   movlw 0x00          W         <= 0x00
	#40
	assert(core.w_reg_out == 8'h00) else $fatal();

	//test 143, 11100100000000 //143.   iorlw 0x00          W         <= 0x00 | 0x00 = 0x00 and Z
	#40
	assert(core.w_reg_out == 8'h00) else $fatal();
	assert(core.status_z == 1) else $fatal();

	// # # # #  # # # # # # # # SUBLW # # # # # # # # # # # # # # # # #

	//test 150, 11000010101011 //150.   movlw 0xAB          W         <= 0xAB
	#40
	assert(core.w_reg_out == 8'hab) else $fatal();

	//test 151, 11110010111011 //151.   sublw 0xBB          W         <= 0xBB - 0xAB = 0x10, !Z, C, DC
	#40
	assert(core.w_reg_out == 8'h10) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b011) else $fatal();

	//test 152, 11110000001111 //152.   sublw 0x09          W         <= 0x0F - 0x10 = 0xFF, !Z, !C, DC
	#40
	assert(core.w_reg_out == 8'hff) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b010) else $fatal();

	//test 153, 11110011111111 //153.   sublw 0xFF          W         <= 0xFF - 0xFF = 0x00, Z, C, DC
	#40
	assert(core.w_reg_out == 8'h00) else $fatal();
	assert(core.status_reg_out[2:0] == 3'b111) else $fatal();

	// # # # #  # # # # # # # # XORLW # # # # # # # # # # # # # # # # #

	//test 160, 11000010101011 //160.   movlw 0xAB          W         <= 0xAB
	#40
	assert(core.w_reg_out == 8'hab) else $fatal();

	//test 161, 11101010100100 //161.   xorlw 0xA5          W         <= 0xAB ^ 0xA5 = 0x0F, !Z
	#40
	assert(core.w_reg_out == 8'h0f) else $fatal();
	assert(core.status_z == 0) else $fatal();

	//test 162, 11101000001111 //162.   xorlw 0x0F          W         <= 0x0F ^ 0x0F = 0x00, Z
	#40
	assert(core.w_reg_out == 8'h00) else $fatal();
	assert(core.status_z == 1) else $fatal();

/*
//address xx, which is 10100000000001 //xx.	goto 1 		PC <= 0x01 (the first movlw instruction)
#40
assert(core.instr_flush == 1);

#flushed address 1, so it's just a nop
#40
assert(core.instr_current == 0) else $fatal();
assert(core.pc_out == 1) else $fatal();
*/
	$display("ALL TESTS PASSED SUCCESSFULLY");
	$finish();
end
endmodule
