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
sim:/picmicro_midrange_core/control/q_count \
{sim:/picmicro_midrange_core/regfile/gpRegistersA[0]} 
force -freeze sim:/picmicro_midrange_core/rst 1 0
force -freeze sim:/picmicro_midrange_core/clk 1 25, 0 {75 ps} -r 100
run
force -freeze sim:/picmicro_midrange_core/rst 0 0
run
#check to make sure the output is correct
if {[examine -radix unsigned sim:/picmicro_midrange_core/pc_out] != 0} {
    echo "FAIL TEST 1a"
    abort
}
if {[examine -radix unsigned sim:/picmicro_midrange_core/control/q_count] != 1} {
    echo "FAIL TEST 1b"
    abort
}
if {[examine -radix unsigned sim:/picmicro_midrange_core/instr_current] != 0} {
    echo "FAIL TEST 1c"
    abort
}
run
if {[examine -radix unsigned sim:/picmicro_midrange_core/control/q_count] != 2} {
    echo "FAIL TEST 2a"
    abort
}
run
if {[examine -radix unsigned sim:/picmicro_midrange_core/control/q_count] != 3} {
    echo "FAIL TEST 3a"
    abort
}
run
if {[examine -radix unsigned sim:/picmicro_midrange_core/control/q_count] != 0} {
    echo "FAIL TEST 4a"
    abort
}
run
run
run

run
run
run
run
if {[examine -radix hexadecimal sim:/picmicro_midrange_core/w_reg_out] != {ab}} {
    echo "FAIL TEST 5a"
    abort
}

run
run
run
run
if {[examine -radix hexadecimal {sim:/picmicro_midrange_core/regfile/gpRegistersA[0]}] != {ab}} {
    echo "FAIL TEST 6a"
    abort
}

echo "ALL TESTS PASSED"
