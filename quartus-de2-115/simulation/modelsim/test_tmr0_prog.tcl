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
sim:/picmicro_midrange_core/tmr0wdt/tmr0_reg_out






force -freeze sim:/picmicro_midrange_core/rst_ext 1 0
force -freeze sim:/picmicro_midrange_core/clk 1 25, 0 {75 ps} -r 100
#reset the core
run
#drop reset and finish first (reset) cycle
force -freeze sim:/picmicro_midrange_core/rst_ext 0 0
run
run
run

#execute 01011010000011 //00.    bsf STATUS, RP0     change to bank 1
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/status_reg_out[5]}] != 1} {
    echo "FAIL TEST 65"
    abort
}

#execute 01001010000001 //01.    bcf OPTION, T0CS    clr bit 5 of OPTION
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/option_reg_out[5]}] != 0} {
    echo "FAIL TEST 75"
    abort
}
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 0} {
    echo "FAIL TEST 79"
    abort
}

#execute 00000000000000 //02.    nop       //TMR0 should increase by 1 for each cycle of the clock
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 1} {
    echo "FAIL TEST 89"
    abort
}

#execute 01000000000001 //03.    bcf OPTION, PS0 //clear the prescaler select bits, setting it to div/2  
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 2} {
    echo "FAIL TEST 99"
    abort
}

#execute 01000010000001 //04.    bcf OPTION, PS1   
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 3} {
    echo "FAIL TEST 109"
    abort
}

#execute 01000100000001 //05.    bcf OPTION, PS2    
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 4} {
    echo "FAIL TEST 119"
    abort
}

#execute 01000110000001 //06.    bcf OPTION, PSA    clr bit 3 of OPTION, enabling the prescaler 
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 5} {
    echo "FAIL TEST 129"
    abort
}

#execute 00000000000000 //07.    nop       //now the timer should increase every second instruction
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 5} {
    echo "FAIL TEST 139"
    abort
}

#execute 00000000000000 //08.    nop       
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 6} {
    echo "FAIL TEST 149"
    abort
}

#execute 00000000000000 //09.    nop       
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 6} {
    echo "FAIL TEST 159"
    abort
}

#execute 01010000000001 //0A.    bsf OPTION, PS0 //set the prescaler PS0, setting it to div/4 
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 7} {
    echo "FAIL TEST 169"
    abort
}

#execute 00000000000000 //0B.    nop       
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 7} {
    echo "FAIL TEST 179"
    abort
}

#execute 00000000000000 //0C.    nop       
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 7} {
    echo "FAIL TEST 189"
    abort
}

#execute 00000000000000 //0D.    nop       
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 7} {
    echo "FAIL TEST 199"
    abort
}

#execute 00000000000000 //0E.    nop       
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 8} {
    echo "FAIL TEST 209"
    abort
}

#execute 00000000000000 //0F.    nop       
run
run
run
run
if {[examine -radix unsigned {sim:/picmicro_midrange_core/tmr0_reg_out}] != 8} {
    echo "FAIL TEST 219"
    abort
}



#all tests passed
echo "ALL TMR0 TESTS PASSED"
abort