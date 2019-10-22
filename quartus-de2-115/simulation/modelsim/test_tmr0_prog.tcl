vlog ../../../verilog/program_memory.v +define+test_tmr0=1
vsim work.picmicro_midrange_core
add wave -position insertpoint  \
sim:/picmicro_midrange_core/clk \
sim:/picmicro_midrange_core/rst_ext \
sim:/picmicro_midrange_core/rst \
sim:/picmicro_midrange_core/instr_rd_en \
sim:/picmicro_midrange_core/instr_flush \
sim:/picmicro_midrange_core/instr_current \
sim:/picmicro_midrange_core/instr_j \
sim:/picmicro_midrange_core/pc_out \
sim:/picmicro_midrange_core/pc_incr_en \
sim:/picmicro_midrange_core/pc_j_en \
sim:/picmicro_midrange_core/pc_j_and_push_en \
sim:/picmicro_midrange_core/pc_j_by_pop_en \
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
{sim:/picmicro_midrange_core/regfile/gpRegistersA[2]} \
sim:/picmicro_midrange_core/pc/hs/tos \
{sim:/picmicro_midrange_core/pc/hs/stack[0]} \
{sim:/picmicro_midrange_core/pc/hs/stack[1]} \
{sim:/picmicro_midrange_core/pc/hs/stack[2]} \
sim:/picmicro_midrange_core/option_reg_out \
sim:/picmicro_midrange_core/tmr0wdt/tmr0_cnt_en \
sim:/picmicro_midrange_core/tmr0wdt/tmr0_reg_in \
sim:/picmicro_midrange_core/tmr0wdt/tmr0_reg_wr_en \
sim:/picmicro_midrange_core/tmr0wdt/tmr0_reg_out \
sim:/picmicro_midrange_core/tmr0wdt/* \
sim:/picmicro_midrange_core/tmr0wdt/wdt_post_tmr0_pre/*
force -freeze sim:/picmicro_midrange_core/rst_ext 1 0
force -freeze sim:/picmicro_midrange_core/clk 1 25, 0 {75 ps} -r 100
#reset the core
run
#drop reset and finish first (reset) cycle
force -freeze sim:/picmicro_midrange_core/rst_ext 0 0
run
run
run

#execute 00000110000001 //00.    clrf TMR0 //reset TMR0, tmr0 should not increment
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out[5]}] != 0} {
    echo "FAIL TEST 65"
    abort
}

#execute 01011010000011 //01.    bsf STATUS, RP0     change to bank 1
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/status_reg_out[5]}] != 1} {
    echo "FAIL TEST 75"
    abort
}
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 0} {
    echo "FAIL TEST 79"
    abort
}

#execute 01001010000001 //02.    bcf OPTION, T0CS    clr bit 5 of OPTION
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/option_reg_out[5]}] != 0} {
    echo "FAIL TEST 89"
    abort
}
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 0} {
    echo "FAIL TEST 93"
    abort
}

#execute 00000000000000 //03.    nop //tmr0 should increment
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 1} {
    echo "FAIL TEST 103"
    abort
}

#execute 00000000000000 //04.    nop //tmr0 should increment
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 2} {
    echo "FAIL TEST 113"
    abort
}

#execute 00000000000000 //05.    nop       //TMR0 should increase by 1 for each cycle of the clock
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 3} {
    echo "FAIL TEST 123"
    abort
}

#execute 01000000000001 //06.    bcf OPTION, PS0 //clear the prescaler select bits, setting it to div/2  
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 4} {
    echo "FAIL TEST 133"
    abort
}

#execute 01000010000001 //07.    bcf OPTION, PS1   
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 5} {
    echo "FAIL TEST 143"
    abort
}

#execute 01000100000001 //08.    bcf OPTION, PS2    
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 6} {
    echo "FAIL TEST 153"
    abort
}

#execute 01000110000001 //09.    bcf OPTION, PSA    clr bit 3 of OPTION, enabling the prescaler 
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 7} {
    echo "FAIL TEST 163"
    abort
}

#execute 00000000000000 //0A.    nop       //now the timer should increase every second instruction
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 8} {
    echo "FAIL TEST 173"
    abort
}

#execute 00000000000000 //0B.    nop       
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 8} {
    echo "FAIL TEST 183"
    abort
}

#execute 01010000000001 //0C.    bsf OPTION, PS0 //set the prescaler PS0, setting it to div/4 . However, it will be only 3 cycles to the next increment due to current value of prescaler
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 9} { 
    echo "FAIL TEST 193"
    abort
}

#execute 00000000000000 //0D.    nop       
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 9} {
    echo "FAIL TEST 203"
    abort
}

#execute 00000000000000 //0E.    nop       
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 9} {
    echo "FAIL TEST 213"
    abort
}

#execute 00000000000000 //0F.    nop       
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 10} {
    echo "FAIL TEST 215"
    abort
}

#execute 00000000000000 //10.    nop       
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 10} {
    echo "FAIL TEST 225"
    abort
}

#execute 00000000000000 //11.    nop       
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 10} {
    echo "FAIL TEST 235"
    abort
}

#execute 00000000000000 //12.    nop       
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 10} {
    echo "FAIL TEST 245"
    abort
}

#execute 01010110000001 //13.    bsf OPTION, PSA    clr bit 3 of OPTION, disabling the prescaler
run
run
run
run


#execute 01001010000011 //14.    bcf STATUS, RP0    change to bank 0
run
run
run
run


#execute 11000011111101 //15.    movlw 0xFD
run
run
run
run


#execute 00000010000001 //16.    movwf TMR0 //tmr0 should not increment
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/tmr0_reg_out}] != {fd}} {
    echo "FAIL TEST 276"
    abort
}

#execute 00000000000000 //17.    nop //tmr0 should not increment
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/tmr0_reg_out}] != {fd}} {
    echo "FAIL TEST 286"
    abort
}

#execute 00000000000000 //18.    nop //tmr0 should not increment
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/tmr0_reg_out}] != {fd}} {
    echo "FAIL TEST 296"
    abort
}

#execute 00000000000000 //19.    nop //tmr0 should increment
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/tmr0_reg_out}] != {fe}} {
    echo "FAIL TEST 306"
    abort
}

#execute 00000000000000 //1A.    nop //tmr0 should increment
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/tmr0_reg_out}] != {ff}} {
    echo "FAIL TEST 316"
    abort
}
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0if_set_en}] != 0} {
    echo "FAIL TEST 320"
    abort
}

#execute 00000000000000 //1B.    nop //tmr0 should overflow
run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/tmr0_reg_out}] != {00}} {
    echo "FAIL TEST 330"
    abort
}
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0if_set_en}] != 1} {
    echo "FAIL TEST 334"
    abort
}


#all tests passed
echo "ALL TMR0 TESTS PASSED"
abort