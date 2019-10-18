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
    echo "FAIL TEST 53"
    abort
}

#this instruction should have been flushed as we jump to 50
run
run
run
run
if {[examine -radix unsigned sim:/picmicro_midrange_core/instr_current] != 0} {
    echo "FAIL TEST 63"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/pc_out] != {0050}} {
    echo "FAIL TEST 67"
    abort
}

#execute 10000000000001 //50.    call 0x01
run
run
run
run
if {[examine -radix binary sim:/picmicro_midrange_core/instr_flush] != 1} { 
    echo "FAIL TEST 77"
    abort
}
if {[examine -radix binary sim:/picmicro_midrange_core/pc_j_and_push_en] != 1} { 
    echo "FAIL TEST 85"
    abort
}

#this instruction should have been flushed as we jump to 0x01
run
run
run
run
if {[examine -radix unsigned sim:/picmicro_midrange_core/instr_current] != 0} {
    echo "FAIL TEST 95"
    abort
}
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/pc_out] != {0001}} {
    echo "FAIL TEST 99"
    abort
}
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/pc/hs/stack[0]}] != {0051}} {
    echo "FAIL TEST 103"
    abort
}

#all tests passed
echo "ALL CONTROL TESTS PASSED"
abort