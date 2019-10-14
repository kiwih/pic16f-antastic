vsim work.picmicro_midrange_core
add wave -position insertpoint  \
sim:/picmicro_midrange_core/clk \
sim:/picmicro_midrange_core/rst \
sim:/picmicro_midrange_core/instr_rd_en \
sim:/picmicro_midrange_core/instr_flush \
sim:/picmicro_midrange_core/instr_current \
sim:/picmicro_midrange_core/pc_out \
sim:/picmicro_midrange_core/pc_incr_en \
sim:/picmicro_midrange_core/pc_j_en \
sim:/picmicro_midrange_core/w_reg_out \
sim:/picmicro_midrange_core/alu_op \
sim:/picmicro_midrange_core/alu_d \
sim:/picmicro_midrange_core/alu_d_wr_en \
sim:/picmicro_midrange_core/alu_out_f_wr_en \
sim:/picmicro_midrange_core/alu_out_w_wr_en \
sim:/picmicro_midrange_core/alu_out \
sim:/picmicro_midrange_core/alu_out_z \
sim:/picmicro_midrange_core/alu_out_z_wr_en \
sim:/picmicro_midrange_core/status_z \
sim:/picmicro_midrange_core/status_c \
sim:/picmicro_midrange_core/status_reg_out \
sim:/picmicro_midrange_core/control/q_count \
{sim:/picmicro_midrange_core/regfile/gpRegistersA[0]} \
{sim:/picmicro_midrange_core/regfile/gpRegistersA[1]} \
{sim:/picmicro_midrange_core/regfile/gpRegistersA[2]} 
force -freeze sim:/picmicro_midrange_core/rst 1 0
force -freeze sim:/picmicro_midrange_core/clk 1 25, 0 {75 ps} -r 100

#reset the core
run

#drop reset and run first cycle
force -freeze sim:/picmicro_midrange_core/rst 0 0
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

#address 5, which is 00011100100000 //addwf 0 0x20	W <= W + mem[0x20] = 0xAB + 0xCD = Carry and 0x78
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

#address 13, which is 00000110000011 //13.	clrf STATUS	STATUS <= 0x00 and Z (since the clrf sets the Z) = 0x04
run
run
run
run
if {[examine -radix binary sim:/picmicro_midrange_core/status_reg_out] != 00000100} {
    echo "FAIL TEST 13a"
    abort
}

#address 14, which is 00100000100000 //14.	movfw 0 STATUS	W <= STATUS = 0x04 and !Z
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {04}} {
    echo "FAIL TEST 14a"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/status_reg_out] != {00}} {
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
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/status_reg_out] != {04}} {
    echo "FAIL TEST 15b"
    abort
}

#address 16, which is 10100000000001 //16.	goto 1 		PC <= 0x01 (the first movlw instruction)
run
run
run
run
if {[examine -radix binary sim:/picmicro_midrange_core/instr_flush] != 1} { 
    echo "FAIL TEST 16a"
    abort
}

#flushed address 1, so it's just a nop
run
run
run
run
if {[examine -radix unsigned sim:/picmicro_midrange_core/instr_current] != 0} {
    echo "FAIL TEST 16b"
    abort
}
if {[examine -radix unsigned sim:/picmicro_midrange_core/pc_out] != 1} {
    echo "FAIL TEST 16c"
    abort
}



echo "ALL TESTS PASSED"
