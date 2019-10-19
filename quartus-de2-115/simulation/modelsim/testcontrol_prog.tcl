vlog ../../../verilog/program_memory.v +define+testcontrol=1
vsim work.picmicro_midrange_core
add wave -position insertpoint  \
sim:/picmicro_midrange_core/clk \
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
{sim:/picmicro_midrange_core/pc/hs/stack[2]} 








force -freeze sim:/picmicro_midrange_core/rst 1 0
force -freeze sim:/picmicro_midrange_core/clk 1 25, 0 {75 ps} -r 100
#reset the core
run
#drop reset and finish first (reset) cycle
force -freeze sim:/picmicro_midrange_core/rst 0 0
run
run
run

#execute the first command: 10100001010000 //00.    goto 0x50
run
run
run
run
if {[examine -radix binary sim:/picmicro_midrange_core/instr_flush] != 1} { 
    echo "FAIL TEST 65"
    abort
}

#this instruction should have been flushed as we jump to 50
run
run
run
run
if {[examine -radix unsigned sim:/picmicro_midrange_core/instr_current] != 0} {
    echo "FAIL TEST 75"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/pc_out] != {0050}} {
    echo "FAIL TEST 79"
    abort
}

#execute 10000000000001 //50.    call 0x01
run
run
run
run
if {[examine -radix binary sim:/picmicro_midrange_core/instr_flush] != 1} { 
    echo "FAIL TEST 89"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/pc_j_and_push_en] != 1} { 
    echo "FAIL TEST 93"
    abort
}

#this instruction should have been flushed as we jump to 0x01
run
run
run
run
if {[examine -radix unsigned sim:/picmicro_midrange_core/instr_current] != 0} {
    echo "FAIL TEST 103"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/pc_out] != {0001}} {
    echo "FAIL TEST 107"
    abort
}
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/pc/hs/stack[0]}] != {0051}} {
    echo "FAIL TEST 111"
    abort
}

#execute 10000000000101 //01.    call 0x05 
run
run
run
run
if {[examine -radix binary sim:/picmicro_midrange_core/instr_flush] != 1} { 
    echo "FAIL TEST 121"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/pc_j_and_push_en] != 1} { 
    echo "FAIL TEST 125"
    abort
}

#this instruction should have been flushed as we jump to 0x05
run
run
run
run
if {[examine -radix unsigned sim:/picmicro_midrange_core/instr_current] != 0} {
    echo "FAIL TEST 135"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/pc_out] != {0005}} {
    echo "FAIL TEST 139"
    abort
}
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/pc/hs/stack[1]}] != {0002}} {
    echo "FAIL TEST 143"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/pc/hs/tos] != {2}} {
    echo "FAIL TEST 147"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/pc/hs/out] != {0002}} {
    echo "FAIL TEST 151"
    abort
}

#execute 11000000000101 //05.    movlw 0x05    
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {05}} {
    echo "FAIL TEST 161"
    abort
}

#execute 00000000001000 //06.    return
run
run
run
run
if {[examine -radix binary sim:/picmicro_midrange_core/instr_flush] != 1} { 
    echo "FAIL TEST 171"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/pc/hs/out] != {0002}} {
    echo "FAIL TEST 201"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/pc_j_by_pop_en] != 1} { 
    echo "FAIL TEST 175"
    abort
}

#this instruction should have been flushed as we return to 0x02
run
run
run
run
if {[examine -radix unsigned sim:/picmicro_midrange_core/instr_current] != 0} {
    echo "FAIL TEST 185"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/pc_out] != {0002}} {
    echo "FAIL TEST 189"
    abort
}
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/pc/hs/stack[1]}] != {0002}} {
    echo "FAIL TEST 193"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/pc/hs/tos] != {1}} {
    echo "FAIL TEST 197"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/pc/hs/out] != {0051}} {
    echo "FAIL TEST 201"
    abort
}

#execute 11000000000010 //02.    movlw 0x02   
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {02}} {
    echo "FAIL TEST 215"
    abort
}

#execute 00000000001000 //03.    return
run
run
run
run
if {[examine -radix binary sim:/picmicro_midrange_core/instr_flush] != 1} { 
    echo "FAIL TEST 225"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/pc/hs/out] != {0051}} {
    echo "FAIL TEST 229"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/pc_j_by_pop_en] != 1} { 
    echo "FAIL TEST 233"
    abort
}

#this instruction should have been flushed as we return to 0x51
run
run
run
run
if {[examine -radix unsigned sim:/picmicro_midrange_core/instr_current] != 0} {
    echo "FAIL TEST 243"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/pc_out] != {0051}} {
    echo "FAIL TEST 247"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/pc/hs/tos] != {0}} {
    echo "FAIL TEST 251"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/pc/hs/out] != {0000}} {
    echo "FAIL TEST 255"
    abort
}

#execute 10000000000100 //51.    call 0x04
run
run
run
run
if {[examine -radix binary sim:/picmicro_midrange_core/instr_flush] != 1} { 
    echo "FAIL TEST 265"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/pc_j_and_push_en] != 1} { 
    echo "FAIL TEST 269"
    abort
}

#this instruction should have been flushed as we jump to 0x04
run
run
run
run
if {[examine -radix unsigned sim:/picmicro_midrange_core/instr_current] != 0} {
    echo "FAIL TEST 279"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/pc_out] != {0004}} {
    echo "FAIL TEST 283"
    abort
}
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/pc/hs/stack[0]}] != {0052}} {
    echo "FAIL TEST 287"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/pc/hs/tos] != {1}} {
    echo "FAIL TEST 291"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/pc/hs/out] != {0052}} {
    echo "FAIL TEST 295"
    abort
}

#execute 11010011110001 //04.    retlw 0xF1
run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {f1}} {
    echo "FAIL TEST 305"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/instr_flush] != 1} { 
    echo "FAIL TEST 309"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/pc/hs/out] != {0052}} {
    echo "FAIL TEST 313"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/pc_j_by_pop_en] != 1} { 
    echo "FAIL TEST 317"
    abort
}

#this instruction should have been flushed as we return to 0x52
run
run
run
run
if {[examine -radix unsigned sim:/picmicro_midrange_core/instr_current] != 0} {
    echo "FAIL TEST 327"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/pc_out] != {0052}} {
    echo "FAIL TEST 331"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/pc/hs/tos] != {0}} {
    echo "FAIL TEST 335"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/pc/hs/out] != {0000}} {
    echo "FAIL TEST 339"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {f1}} {
    echo "FAIL TEST 343"
    abort
}

#all tests passed
echo "ALL CONTROL TESTS PASSED"
abort