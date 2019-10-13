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
sim:/picmicro_midrange_core/w_reg_wr_en \
sim:/picmicro_midrange_core/w_reg_out \
sim:/picmicro_midrange_core/alu_op \
sim:/picmicro_midrange_core/alu_out
add wave -position insertpoint  \
sim:/picmicro_midrange_core/control/q_count
force -freeze sim:/picmicro_midrange_core/rst 1 0
force -freeze sim:/picmicro_midrange_core/clk 1 0, 0 {50 ps} -r 100
run
force -freeze sim:/picmicro_midrange_core/rst 0 0
