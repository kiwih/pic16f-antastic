vsim work.picmicro_midrange_core
add wave -position insertpoint  \
sim:/picmicro_midrange_core/clk \
sim:/picmicro_midrange_core/rst_ext \
sim:/picmicro_midrange_core/rst \
sim:/picmicro_midrange_core/instr_rd_en \
sim:/picmicro_midrange_core/instr_flush \
sim:/picmicro_midrange_core/instr_current \
sim:/picmicro_midrange_core/pc_out \
sim:/picmicro_midrange_core/pc_incr_en \
sim:/picmicro_midrange_core/pc_j_en \
sim:/picmicro_midrange_core/w_reg_out \
sim:/picmicro_midrange_core/f_wr_en \
sim:/picmicro_midrange_core/w_wr_en \
sim:/picmicro_midrange_core/alu_sel_l \
sim:/picmicro_midrange_core/a/op_lf \
sim:/picmicro_midrange_core/a/op_w \
sim:/picmicro_midrange_core/a/op \
sim:/picmicro_midrange_core/alu_status_wr_en \
sim:/picmicro_midrange_core/alu_out \
sim:/picmicro_midrange_core/alu_out_c_wr_en \
sim:/picmicro_midrange_core/alu_out_c \
sim:/picmicro_midrange_core/alu_out_z_wr_en \
sim:/picmicro_midrange_core/alu_out_z \
sim:/picmicro_midrange_core/alu_bit_test_res \
sim:/picmicro_midrange_core/bit_test_reg_out \
sim:/picmicro_midrange_core/status_z \
sim:/picmicro_midrange_core/status_c \
sim:/picmicro_midrange_core/status_reg_out \
sim:/picmicro_midrange_core/control/q_count \
{sim:/picmicro_midrange_core/regfile/gpRegistersA[0]} \
{sim:/picmicro_midrange_core/regfile/gpRegistersA[1]} \
{sim:/picmicro_midrange_core/regfile/gpRegistersA[2]} 
force -freeze sim:/picmicro_midrange_core/rst_ext 1 0
force -freeze sim:/picmicro_midrange_core/clk 1 25, 0 {75 ps} -r 100

#reset the core
run

#drop reset and run first cycle
force -freeze sim:/picmicro_midrange_core/rst_ext 0 0
run

#check to make sure the output is correct
if {[examine -radix unsigned sim:/picmicro_midrange_core/pc_out] != 0} {
    echo "FAIL TEST -1a"
    abort
}
if {[examine -radix unsigned sim:/picmicro_midrange_core/control/q_count] != 1} {
    echo "FAIL TEST -1b"
    abort
}
if {[examine -radix unsigned sim:/picmicro_midrange_core/instr_current] != 0} {
    echo "FAIL TEST -1c"
    abort
}

#check CPU is advancing Q count
run
if {[examine -radix unsigned sim:/picmicro_midrange_core/control/q_count] != 2} {
    echo "FAIL TEST -1d"
    abort
}
run
if {[examine -radix unsigned sim:/picmicro_midrange_core/control/q_count] != 3} {
    echo "FAIL TEST -1e"
    abort
}

#begin the command at address 0, which is a nop
run
if {[examine -radix unsigned sim:/picmicro_midrange_core/control/q_count] != 0} {
    echo "FAIL TEST 0a"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/instr_current] != 00000000000000} {
    echo "FAIL TEST 0b"
    abort
}
run
run
run

#begin the command at address 1, which is 11000010101011 //movlw 0xAB	W <= 0xAB
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {ab}} {
    echo "FAIL TEST 1a"
    abort
}

#begin the command at address 2, which is 00000010100000 //movwf 0x20	mem[0x20] <= W = 0xAB
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[0]}] != {ab}} {
    echo "FAIL TEST 2a"
    abort
}

#begin the command at address 3, which is 11000011001101 //movlw 0xCD	W <= 0xCD
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {cd}} {
    echo "FAIL TEST 3a"
    abort
}

#begin the command at address 4, which is 00000010100001 //movwf 0x21	mem[0x21] <= W = 0xCD
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[1]}] != {cd}} {
    echo "FAIL TEST 4a"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/status_c] != 0} { #ensure we have c=0 before the next command
    echo "FAIL TEST 4b"
    abort
}

#address 5, which is 00011100100000 //addwf 0 0x20	W <= W + mem[0x20] = 0xAB + 0xCD = Carry and 0x78 and DC and !Z
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {78}} {
    echo "FAIL TEST 5a"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/status_c] != 1} {
    echo "FAIL TEST 5b"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/status_dc] != 1} {
    echo "FAIL TEST 5c"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/status_z] != 0} {
    echo "FAIL TEST 5d"
    abort
}

#address 6, which is 00100000100000 //6.	movfw 1 0x20	W <= mem[0x20] = 0xAB
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {ab}} {
    echo "FAIL TEST 6a"
    abort
}

#address 7, which is 00010100100001 //7.	andwf 0 0x21	W <= W & mem[0x21] = 0xAB & 0xCD = 0x89
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {89}} {
    echo "FAIL TEST 7a"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/status_z] != 0} { #ensure we have z=0 before the next command
    echo "FAIL TEST 7b"
    abort
}

#address 8, which is 00000110100001 //8.	clrf 0x21	mem[0x21] <= 0x00 and Z = 1
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[1]}] != {00}} {
    echo "FAIL TEST 8a"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/status_z] != 1} { #clr commands should set z = 1
    echo "FAIL TEST 8b"
    abort
}

#address 9, which is 00000110100010 //9.	clrf 0x22	mem[0x22] <= 0x00 and Z = 1
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[2]}] != {00}} {
    echo "FAIL TEST 9a"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/status_z] != 1} { #clr commands should set z = 1
    echo "FAIL TEST 9b"
    abort
}

#address 10, which is 00010100100000 //10.	andwf 0 0x20	W <= W & mem[0x20] = 0x89 & 0xAB = 0x89 and !Z
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {89}} {
    echo "FAIL TEST 10a"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/status_z] != 0} { 
    echo "FAIL TEST 10b"
    abort
}
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[0]}] != {ab}} { #check that mem[0x20] is still 0xab before next command
    echo "FAIL TEST 10c"
    abort
}

#address 11, which is 00010110100000 //11.	andwf 1 0x20	mem[0x20] <= W & mem[0x20] = 0x89 & 0xAB = 0x89 and !Z
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[0]}] != {89}} {
    echo "FAIL TEST 11a"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/status_z] != 0} { 
    echo "FAIL TEST 11b"
    abort
}

#address 12, which is 00010100100010 //12.	andwf 0 0x22	W <= W & mem[0x22] = 0x89 & 0x00 = 0x00 and Z 
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {00}} {
    echo "FAIL TEST 12a"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/status_z] != 1} { 
    echo "FAIL TEST 12b"
    abort
}

#address 13, which is 00000110000011 //13.	clrf STATUS	STATUS <= 0x00 and Z (since the clrf sets the Z) = 0x1c (the power bits are still set)
run
run
run
run
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 100} {
    echo "FAIL TEST 13a"
    abort
}

#address 14, which is 00100000100000 //14.	movfw 0 STATUS	W <= STATUS = 0x04 and !Z
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {1c}} {
    echo "FAIL TEST 14a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 000} {
    echo "FAIL TEST 14b"
    abort
}

#address 15, which is 00000100000000 //15.	clrw		W <= 0x00 and Z
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {00}} {
    echo "FAIL TEST 15a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 100} {
    echo "FAIL TEST 15b"
    abort
}

#address 16, which is 00100110100000 //16.	comf 1 0x20	mem[0x20] <= ~mem[0x20] = 0x76
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[0]}] != {76}} {
    echo "FAIL TEST 16a"
    abort
}

#address 17, which is 00100100100001 //17.	comf 0 0x21	W <= ~mem[0x21] = 0xFF
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {ff}} {
    echo "FAIL TEST 17a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 000} {
    echo "FAIL TEST 17b"
    abort
}

#address 18, which is 00100110100001 //18.	comf 1 0x21	mem[0x21] <= ~mem[0x21] = 0xFF
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[1]}] != {ff}} {
    echo "FAIL TEST 18a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 000} {
    echo "FAIL TEST 18b"
    abort
}

#address 19, which is 00101010100000 //19.	incf 1 0x20	mem[0x20] <= mem[0x20] + 1 = 0x76 + 1 = 0x77
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[0]}] != {77}} {
    echo "FAIL TEST 19a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 000} {
    echo "FAIL TEST 19b"
    abort
}

#address 20, which is 00101000100001 //20.	incf 0 0x21	W <= mem[0x21] + 1 = 0xFF + 1 = 0x00 and Z
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {00}} {
    echo "FAIL TEST 20a"
    abort
}
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[1]}] != {ff}} {
    echo "FAIL TEST 20b"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 100} {
    echo "FAIL TEST 20c"
    abort
}

#address 21, which is 11000000000001 //21.	movlw 0x01	W <= 0x01
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {01}} {
    echo "FAIL TEST 21a"
    abort
}

#address 22, which is 00000010100010 //22.	movwf 0x22	mem[0x22] <= W = 0x01
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[2]}] != {01}} {
    echo "FAIL TEST 22a"
    abort
}

#address 23, which is 00001110100000 //23.	decf 1 0x20	mem[0x20] <= mem[0x20] - 1 = 0x77 - 1 = 0x76
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[0]}] != {76}} {
    echo "FAIL TEST 23a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 000} {
    echo "FAIL TEST 23b"
    abort
}

#address 24, which is 00001100100010 //24.	decf 0 0x22	W <= mem[0x22] - 1 = 0x01 - 1 = 0x00 and Z
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {00}} {
    echo "FAIL TEST 24a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 100} {
    echo "FAIL TEST 24b"
    abort
}

#address 25, which is 00010000100000 //25.	iorwf 0 0x20	W <= W | mem[0x20] = 0x00 | 0x76 = 0x76
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {76}} {
    echo "FAIL TEST 25a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 000} {
    echo "FAIL TEST 25b"
    abort
}

#address 26, which is 00010000100010 //26.	iorwf 0 0x21	W <= W | mem[0x22] = 0x76 | 0x01 = 0x77
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {77}} {
    echo "FAIL TEST 26a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 000} {
    echo "FAIL TEST 26b"
    abort
}

# # # # # # # # # # # # #test decfsz # # # # # # # # # # #

#address 27, which is 00010010100000 //27.	iorwf 1 0x20	mem[0x20] <= W | mem[0x20] = 0x77 | 0x76 = 0x77
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[0]}] != {77}} {
    echo "FAIL TEST 27a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 000} {
    echo "FAIL TEST 27b"
    abort
}

#address 28, which is 00101110100000 //28.	decfsz 1 0x20	mem[0x20] <= mem[0x20] - 1 SZ = 0x77 - 1 SZ = 0x76, !Z, NO SKIP
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[0]}] != {76}} {
    echo "FAIL TEST 28a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 000} {
    echo "FAIL TEST 28b"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/instr_flush] != 0} { 
    echo "FAIL TEST 28c"
    abort
}

#address 29, which is 11000010101011 //29.	movlw 0xAB	W <= 0xAB
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {ab}} {
    echo "FAIL TEST 29a"
    abort
}

#address 30, which is 00101100100010 //30.	decfsz 0 0x22	W <= mem[0x22] - 1 SZ = 0x01 - 1 SZ = 0x00 Z, SKIP
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {00}} {
    echo "FAIL TEST 29a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 100} {
    echo "FAIL TEST 30b"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/instr_flush] != 1} { 
    echo "FAIL TEST 30c"
    abort
}

#address 31, which is 11000010101011 //31.	movlw 0xAB	SKIPPED W <= 0xAB
run
run
run
run
if {[examine -radix unsigned sim:/picmicro_midrange_core/instr_current] != 0} {
    echo "FAIL TEST 31a"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {00}} {
    echo "FAIL TEST 31b"
    abort
}

#address 32, which is 00101110100010 //32.	decfsz 0 0x22	mem[0x22] <= mem[0x22] - 1 SZ = 0x01 - 1 SZ = 0x00 Z, SKIP
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[2]}] != {00}} {
    echo "FAIL TEST 32a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 100} {
    echo "FAIL TEST 32b"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/instr_flush] != 1} { 
    echo "FAIL TEST 32c"
    abort
}

#address 33, which is 11000010101011 //33.	movlw 0xAB	SKIPPED W <= 0xAB
run
run
run
run
if {[examine -radix unsigned sim:/picmicro_midrange_core/instr_current] != 0} {
    echo "FAIL TEST 33a"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {00}} {
    echo "FAIL TEST 33b"
    abort
}

#address 34, which is 00101110100000 //34.	decfsz 1 0x20	mem[0x20] <= mem[0x20] - 1 SZ = 0x76 - 1 SZ = 0x75, !Z, NO SKIP
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[0]}] != {75}} {
    echo "FAIL TEST 34a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 000} {
    echo "FAIL TEST 34b"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/instr_flush] != 0} { 
    echo "FAIL TEST 34c"
    abort
}

#address 35, which is 11000011001101 //35.	movlw 0xCD	W <= 0xCD
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {cd}} {
    echo "FAIL TEST 35a"
    abort
}

# # # # # # # # # # # # #test incfsz # # # # # # # # # # #

#address 36, which is 00111100100000 //36.    incfsz 0 0x20       W <= mem[0x20] + 1 SZ = 0x75 + 1 SZ = 0x76, !Z, NO SKIP
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {76}} {
    echo "FAIL TEST 36a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 000} {
    echo "FAIL TEST 36b"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/instr_flush] != 0} { 
    echo "FAIL TEST 36c"
    abort
}

#address 37, which is 11000011111111 //37.    movlw 0xFF          W <= 0xFF
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {ff}} {
    echo "FAIL TEST 37a"
    abort
}

#address 38, which is 00000010110000 //38.    movwf 0x30          mem[0x30] <= W = 0xFF
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[16]}] != {ff}} {
    echo "FAIL TEST 38a"
    abort
}

#address 39, which is 00111100110000 //39.    incfsz 0 0x30       W <= mem[0x30] + 1 SZ = 0xFF + 1 SZ = 0x00, Z, SKIP
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {00}} {
    echo "FAIL TEST 39a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 100} {
    echo "FAIL TEST 39b"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/instr_flush] != 1} { 
    echo "FAIL TEST 39c"
    abort
}

#address 40, which is 11000010101011 //40.    movlw 0xAB          SKIPPED W <= 0xAB
run
run
run
run
if {[examine -radix unsigned sim:/picmicro_midrange_core/instr_current] != 0} {
    echo "FAIL TEST 40a"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {00}} {
    echo "FAIL TEST 40b"
    abort
}

#address 41, which is 00111110110000 //41.    incfsz 1 0x30       mem[0x30] <= mem[0x30] + 1 SZ = 0xFF + 1 SZ = 0x00, Z, SKIP
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[16]}] != {00}} {
    echo "FAIL TEST 41a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 100} {
    echo "FAIL TEST 41b"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/instr_flush] != 1} { 
    echo "FAIL TEST 41c"
    abort
}

#address 42, which is 11000010101011 //42.    movlw 0xAB          SKIPPED W <= 0xAB
run
run
run
run
if {[examine -radix unsigned sim:/picmicro_midrange_core/instr_current] != 0} {
    echo "FAIL TEST 42a"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {00}} {
    echo "FAIL TEST 42b"
    abort
}

#address 43, which is 00111110110000 //43.    incfsz 1 0x30       mem[0x30] <= mem[0x30] + 1 SZ = 0x00 + 1 SZ = 0x01, Z, NO SKIP
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[16]}] != {01}} {
    echo "FAIL TEST 43a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 000} {
    echo "FAIL TEST 43b"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/instr_flush] != 0} { 
    echo "FAIL TEST 43c"
    abort
}

#address 44, which is 11000010101011 //44.    movlw 0xAB          W <= 0xAB
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {ab}} {
    echo "FAIL TEST 44a"
    abort
}

# # # # # # # # # # # # rlf # # # # # # # # # # # # #

#address 45, which is 00000010100010 //45.    movwf 0x22          mem[0x22] <= W = 0xAB
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[2]}] != {ab}} {
    echo "FAIL TEST 45a"
    abort
}

#address 46, which is 00110110100010 //46.    rlf 1 0x22          mem[0x22] <= mem[0x22] << 1 = 0x56 and C (Z not affected)
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[2]}] != {56}} {
    echo "FAIL TEST 46a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 001} {
    echo "FAIL TEST 46b"
    abort
}

#address 47, which is 00110100100010 //47.    rlf 0 0x22          W <= mem[0x22] << 1 = 0xAD and !C (Z not affected)
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {ad}} {
    echo "FAIL TEST 47a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 000} {
    echo "FAIL TEST 47b"
    abort
}

# # # # # # # # # # # # rrf # # # # # # # # # # # # #

#address 48, which is 11000010101011 //48.    movlw 0xAB          W <= 0xAB
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {ab}} {
    echo "FAIL TEST 48a"
    abort
}

#address 49, which is 00000010100010 //49.    movwf 0x22          mem[0x22] <= W = 0xAB
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[2]}] != {ab}} {
    echo "FAIL TEST 49a"
    abort
}

#address 50, which is 00110010100010 //50.    rrf 1 0x22          mem[0x22] <= mem[0x22] << 1 = 0x55 and C (Z not affected)
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[2]}] != {55}} {
    echo "FAIL TEST 50a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 001} {
    echo "FAIL TEST 50b"
    abort
}

#address 51, which is 00110010100010 //51.    rrf 1 0x22          mem[0x22] <= mem[0x22] << 1 = 0xAA and C (Z not affected)
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[2]}] != {aa}} {
    echo "FAIL TEST 51a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 001} {
    echo "FAIL TEST 51b"
    abort
}

#address 52, which is 00110000100010 //52.    rrf 0 0x22          W <= mem[0x22] << 1 = 0xd5 and !C (Z not affected)
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {d5}} {
    echo "FAIL TEST 52a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 000} {
    echo "FAIL TEST 52b"
    abort
}

# # # # # # # # # # # # subwf # # # # # # # # # # # # #

#address 53a, which is 11000000101010 //53a.   movlw 0x2A          W <= 0x2A
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {2a}} {
    echo "FAIL TEST 53c_a"
    abort
}

#address 53b, which is 00000010100010 //53b.   movwf 0x22          mem[0x22] <= W = 0x2A
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[2]}] != {2a}} {
    echo "FAIL TEST 53b_a"
    abort
}

#address 53c, which is 11000000010101 //53c.    movlw 0x15          W <= 0x15
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {15}} {
    echo "FAIL TEST 53c_a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 000} {
    echo "FAIL TEST 53c_b"
    abort
}

#address 54, which is 00001010100010 //54.    subwf 1 0x22        mem[0x22] <= mem[0x22] - W = 0x2A - 0x15 = 0x15 !Z C DC 
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[2]}] != {15}} {
    echo "FAIL TEST 54a"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/status_z] != 0} { 
    echo "FAIL TEST 54b"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/status_c] != 1} { 
    echo "FAIL TEST 54c"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/status_dc] != 1} { 
    echo "FAIL TEST 54d"
    abort
}

#address 55, which is 00001000100010 //55.    subwf 0 0x22        W         <= mem[0x22] - W = 0x15 - 0x15 = 0x0 Z C DC
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {00}} {
    echo "FAIL TEST 55a"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/status_z] != 1} { 
    echo "FAIL TEST 55b"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/status_c] != 1} { 
    echo "FAIL TEST 55c"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/status_dc] != 1} { 
    echo "FAIL TEST 55d"
    abort
}

#address 56, which is 11000010101011 //44.    movlw 0xAB          W <= 0xAB
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {ab}} {
    echo "FAIL TEST 56a"
    abort
} 

#address 57, which is 00001010100010 //57.    subwf 1 0x22        mem[0x22] <= mem[0x22] - W = 0x15 - 0xAB = 0x6a !Z !C !DC
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[2]}] != {6a}} {
    echo "FAIL TEST 57a"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/status_z] != 0} { 
    echo "FAIL TEST 57b"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/status_c] != 0} { 
    echo "FAIL TEST 57c"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/status_dc] != 0} { 
    echo "FAIL TEST 57d"
    abort
}

# # # # # # # # # # swapf # # # # # # # # # # #

#test 60, 11000010101011 //60.    movlw 0xAB          W         <= 0xAB
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {ab}} {
    echo "FAIL TEST 60a"
    abort
}

#test 61, which is 00000010100000 //61.    movwf 0x20          mem[0x20] <= W = 0xAB
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[0]}] != {ab}} {
    echo "FAIL TEST 61a"
    abort
}

#test 62, which is 00111000100000 //62.    swapf 0 0x20        W         <= swap(mem[0x20) = swap(0xAB) = 0xBA
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {ba}} {
    echo "FAIL TEST 62a"
    abort
}

#test 63, which is 00111010100000 //63.    swapf 1 0x20        mem[0x20] <= swap(mem[0x20) = swap(0xAB) = 0xBA
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[0]}] != {ba}} {
    echo "FAIL TEST 63a"
    abort
}

# # # # # # # # # # # xorwf # # # # # # # # # # # #

#test 70, 11000010101011 //70.    movlw 0xAB          W         <= 0xAB
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {ab}} {
    echo "FAIL TEST 70a"
    abort
}

#test 71, 00000010100000 //71.    movwf 0x20          mem[0x20] <= W = 0xAB
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[0]}] != {ab}} {
    echo "FAIL TEST 71a"
    abort
}

#test 72, 11000010100101 //72.    movlw 0xA5          W         <= 0xA5
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {a5}} {
    echo "FAIL TEST 72"
    abort
}

#test 73, 00011010100000 //73.    xorwf 0 0x20        mem[0x20] <= mem[0x20] ^ W = 0xAB ^ 0xA5 = 0x0E, !Z
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[0]}] != {0e}} {
    echo "FAIL TEST 73a"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/status_z] != 0} { 
    echo "FAIL TEST 73b"
    abort
}

#test 74, 11000000001110 //74.    movlw 0x0E          W         <= 0x0E
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {0e}} {
    echo "FAIL TEST 74a"
    abort
}

#test 75, 00011000100000 //75.    xorwf 1 0x20        mem[0x20] <= mem[0x20] ^ W = 0xA5 ^ 0xA5 = 0x00, Z
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {00}} {
    echo "FAIL TEST 75a"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/status_z] != 1} { 
    echo "FAIL TEST 75b"
    abort
}

# # # # # # # # # # # # test DC bit # # # # # # # # # # # #

#test 80, 11000000101000 //80.    movlw 0x28          W         <= 0x28
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {28}} {
    echo "FAIL TEST 80a"
    abort
}

#test 81, 00000010100000 //81.    movwf 0x20          mem[0x20] <= W = 0x28
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[0]}] != {28}} {
    echo "FAIL TEST 81a"
    abort
}

#test 82, 11000000011000 //82.    movlw 0x18          W         <= 0x18
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {18}} {
    echo "FAIL TEST 82a"
    abort
}

#test 83, 00011100100000 //83.    addwf 0 0x20        W         <= W + mem[0x20] = 0x28 + 0x18 = 0x40, !C, !Z, DC
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {40}} {
    echo "FAIL TEST 83a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 010} {
    echo "FAIL TEST 83b"
    abort
}

# # # # # # # # # # # test DC bit with subtraction # # # # # # # # # # # 

#test 90, 11000001000000 //90.    movlw 0x40          W         <= 0x40
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {40}} {
    echo "FAIL TEST 90a"
    abort
}

#test 91, 00000010100000 //91.    movwf 0x20          mem[0x20] <= W = 0x40
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[0]}] != {40}} {
    echo "FAIL TEST 91a"
    abort
}

#test 92, 11000000101000 //92.    movlw 0x28          W         <= 0x28
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {28}} {
    echo "FAIL TEST 92a"
    abort
}

#test 93, 00001000100000 //93.    SUBwf 0 0x20        W         <= mem[0x20] - W = 0x40 - 0x28 = 0x18, C, !Z, !DC
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {18}} {
    echo "FAIL TEST 93a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 001} {
    echo "FAIL TEST 93b"
    abort
}

# # # # # # # # # # # # # bcf / bsf # # # # # # # # 3 # # 3 # # # #

#test 100, 11000010101011 //100.   movlw 0xAB          W         <= 0xAB
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {ab}} {
    echo "FAIL TEST 100a"
    abort
}

#test 101, 00000010100000 //101.   movwf 0x20          mem[0x20] <= W = 0xAB
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[0]}] != {ab}} {
    echo "FAIL TEST 101a"
    abort
}

#test 102, 01001110100000 //102.   bcf 7 0x20          mem[0x20] <= clr bit 7 of mem[0x20] = 0xAB clr bit 7 = 0x2B
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[0]}] != {2b}} {
    echo "FAIL TEST 102a"
    abort
}

#test 103, 01010100100000 //103.   bsf 2 0x20          mem[0x20] <= set bit 2 of mem[0x20] = 0x2B set bit 2 = 0x2F
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[0]}] != {2f}} {
    echo "FAIL TEST 103a"
    abort
}

#test 104, 01100000100000 //104.   btfsc 0 0x20        skip next if bit 0 is 0 in mem[0x20], which is 0x2F, so no skip
run
run
run
run
if {[examine -radix binary sim:/picmicro_midrange_core/instr_flush] != 0} { 
    echo "FAIL TEST 104a"
    abort
}

#test 105, 01101000100000 //105.   btfsc 4 0x20        skip next if bit 4 is 0 in mem[0x20], which is 0x2F, so skip
run
run
run
run
if {[examine -radix binary sim:/picmicro_midrange_core/instr_flush] != 1} { 
    echo "FAIL TEST 105a"
    abort
}

#test 106, 11000010101011 //106.   movlw 0xAB          SKIPPED W <= 0xAB
run
run
run
run
if {[examine -radix unsigned sim:/picmicro_midrange_core/instr_current] != 0} {
    echo "FAIL TEST 106a"
    abort
}

#test 107, 01111000100000 //107.   btfsc 0 0x20        skip next if bit 4 is 1 in mem[0x20], which is 0x2F, so no skip
run
run
run
run
if {[examine -radix binary sim:/picmicro_midrange_core/instr_flush] != 0} { 
    echo "FAIL TEST 107a"
    abort
}

#test 108, 01110000100000 //108.   btfsc 4 0x20        skip next if bit 0 is 1 in mem[0x20], which is 0x2F, so skip
run
run
run
run
if {[examine -radix binary sim:/picmicro_midrange_core/instr_flush] != 1} { 
    echo "FAIL TEST 108a"
    abort
}

#test 106, 11000010101011 //109.   movlw 0xAB          SKIPPED W <= 0xAB
run
run
run
run
if {[examine -radix unsigned sim:/picmicro_midrange_core/instr_current] != 0} {
    echo "FAIL TEST 109a"
    abort
}

# # # # # # # # # # # # ADDLW # # # # # # # # # # # #

#test 120, 11000010101011 //120.   movlw 0xAB          W         <= 0xAB
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {ab}} {
    echo "FAIL TEST 120a"
    abort
}

#test 121, 11111000001011 //121.   addlw 0x0B          W         <= 0xAB + 0x0B = 0xB6, !Z, !C, DC
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {b6}} {
    echo "FAIL TEST 121a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 010} {
    echo "FAIL TEST 121b"
    abort
}

#test 122, 11111001001010 //122.   addlw 0x4A           W         <= 0xB6 + 0x4A = 0x00, Z, C, DC
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {00}} {
    echo "FAIL TEST 122a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 111} {
    echo "FAIL TEST 122b"
    abort
}

# # # # # # # # # # # # # ANDLW # # # # # # # # # # # # # # # # #

#test 130, 11000010101011 //130.   movlw 0xAB          W         <= 0xAB
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {ab}} {
    echo "FAIL TEST 130a"
    abort
}

#test 131, 111100100000001 //131.   andlw 0x01          W         <= 0xAB & 0x01 = 0x01 and !Z
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {01}} {
    echo "FAIL TEST 131a"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/status_z] != {0}} {
    echo "FAIL TEST 131b"
    abort
}

#test 132, 11100100010000 //132.   andlw 0x10          W         <= 0x01 & 0x10 = 0x00 and Z
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {00}} {
    echo "FAIL TEST 132a"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/status_z] != {1}} {
    echo "FAIL TEST 132b"
    abort
}

# # # # # # # # # # # # # IORLW # # # # # # # # # # # # # # # # #

#test 140, 11000010101011 //140.   movlw 0xAB          W         <= 0xAB
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {ab}} {
    echo "FAIL TEST 140a"
    abort
}

#test 141, 11100100000100 //141.   iorlw 0x01          W         <= 0xAB | 0x04 = 0xAF and !Z
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {af}} {
    echo "FAIL TEST 141a"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/status_z] != {0}} {
    echo "FAIL TEST 141b"
    abort
}

#test 142, 11000000000000 //142.   movlw 0x00          W         <= 0x00
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {00}} {
    echo "FAIL TEST 142a"
    abort
}

#test 143, 11100100000000 //143.   iorlw 0x00          W         <= 0x00 | 0x00 = 0x00 and Z
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {00}} {
    echo "FAIL TEST 143a"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/status_z] != {1}} {
    echo "FAIL TEST 143b"
    abort
}

# # # # # # # # # # # # # SUBLW # # # # # # # # # # # # # # # # #

#test 150, 11000010101011 //150.   movlw 0xAB          W         <= 0xAB
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {ab}} {
    echo "FAIL TEST 150a"
    abort
}

#test 151, 11110010111011 //151.   sublw 0xBB          W         <= 0xBB - 0xAB = 0x10, !Z, C, DC
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {10}} {
    echo "FAIL TEST 151a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 011} {
    echo "FAIL TEST 151b"
    abort
}

#test 152, 11110000001111 //152.   sublw 0x09          W         <= 0x0F - 0x10 = 0xFF, !Z, !C, DC
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {ff}} {
    echo "FAIL TEST 152a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 010} {
    echo "FAIL TEST 152b"
    abort
}

#test 153, 11110011111111 //153.   sublw 0xFF          W         <= 0xFF - 0xFF = 0x00, Z, C, DC
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {00}} {
    echo "FAIL TEST 153a"
    abort
}
if {[examine -radix binary {sim:/picmicro_midrange_core/status_reg_out[2:0]}] != 111} {
    echo "FAIL TEST 153b"
    abort
}

# # # # # # # # # # # # # XORLW # # # # # # # # # # # # # # # # #

#test 160, 11000010101011 //160.   movlw 0xAB          W         <= 0xAB
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {ab}} {
    echo "FAIL TEST 160a"
    abort
}

#test 161, 11101010100100 //161.   xorlw 0xA5          W         <= 0xAB ^ 0xA5 = 0x0F, !Z
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {0f}} {
    echo "FAIL TEST 161a"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/status_z] != {0}} {
    echo "FAIL TEST 161b"
    abort
}

#test 162, 11101000001111 //162.   xorlw 0x0F          W         <= 0x0F ^ 0x0F = 0x00, Z
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {00}} {
    echo "FAIL TEST 161a"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/status_z] != {1}} {
    echo "FAIL TEST 161b"
    abort
}

#echo "ALL TESTS PASSED"
#abort

#address xx, which is 10100000000001 //xx.	goto 1 		PC <= 0x01 (the first movlw instruction)
run
run
run
run
if {[examine -radix binary sim:/picmicro_midrange_core/instr_flush] != 1} { 
    echo "FAIL TEST xxa"
    abort
}

#flushed address 1, so it's just a nop
run
run
run
run
if {[examine -radix unsigned sim:/picmicro_midrange_core/instr_current] != 0} {
    echo "FAIL TEST xxb"
    abort
}
if {[examine -radix unsigned sim:/picmicro_midrange_core/pc_out] != 1} {
    echo "FAIL TEST xxc"
    abort
}



echo "ALL TESTS PASSED"
