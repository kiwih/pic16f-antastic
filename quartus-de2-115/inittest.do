vsim work.picmicro_midrange_core
add wave -position insertpoint  \
sim:/picmicro_midrange_core/clk \
sim:/picmicro_midrange_core/rst \
sim:/picmicro_midrange_core/extern_peripherals_addr \
sim:/picmicro_midrange_core/extern_peripherals_data_in \
sim:/picmicro_midrange_core/extern_peripherals_data_out \
sim:/picmicro_midrange_core/instr_rd_en \
sim:/picmicro_midrange_core/instr_current \
sim:/picmicro_midrange_core/regfile_wr_en \
sim:/picmicro_midrange_core/regfile_addr \
sim:/picmicro_midrange_core/regfile_data_out \
sim:/picmicro_midrange_core/pcl_reg_wr_en \
sim:/picmicro_midrange_core/pcl_reg_out \
sim:/picmicro_midrange_core/pclath_reg_wr_en \
sim:/picmicro_midrange_core/pclath_reg_out \
sim:/picmicro_midrange_core/status_reg_wr_en \
sim:/picmicro_midrange_core/status_reg_out \
sim:/picmicro_midrange_core/fsr_reg_wr_en \
sim:/picmicro_midrange_core/fsr_reg_out \
sim:/picmicro_midrange_core/intcon_reg_wr_en \
sim:/picmicro_midrange_core/intcon_reg_out \
sim:/picmicro_midrange_core/pir1_reg_wr_en \
sim:/picmicro_midrange_core/pir1_reg_out \
sim:/picmicro_midrange_core/pie1_reg_wr_en \
sim:/picmicro_midrange_core/pie1_reg_out \
sim:/picmicro_midrange_core/pcon_reg_wr_en \
sim:/picmicro_midrange_core/pcon_reg_out \
sim:/picmicro_midrange_core/pc_out \
sim:/picmicro_midrange_core/incr_pc_en \
sim:/picmicro_midrange_core/status_wr \
sim:/picmicro_midrange_core/status_reg_in \
sim:/picmicro_midrange_core/status_irp \
sim:/picmicro_midrange_core/status_rp \
sim:/picmicro_midrange_core/status_n_to \
sim:/picmicro_midrange_core/status_n_pd \
sim:/picmicro_midrange_core/status_z \
sim:/picmicro_midrange_core/status_dc \
sim:/picmicro_midrange_core/status_c \
sim:/picmicro_midrange_core/w_reg_wr_en \
sim:/picmicro_midrange_core/w_reg_out \
sim:/picmicro_midrange_core/alu_status_wr_en \
sim:/picmicro_midrange_core/alu_sel_l \
sim:/picmicro_midrange_core/alu_op \
sim:/picmicro_midrange_core/alu_out \
sim:/picmicro_midrange_core/alu_out_z \
sim:/picmicro_midrange_core/alu_out_z_wr_en \
sim:/picmicro_midrange_core/alu_out_dc \
sim:/picmicro_midrange_core/alu_out_dc_wr_en \
sim:/picmicro_midrange_core/alu_out_c \
sim:/picmicro_midrange_core/alu_out_c_wr_en \
sim:/picmicro_midrange_core/alu_bit_test_res \
sim:/picmicro_midrange_core/control/q_count
force -freeze sim:/picmicro_midrange_core/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/picmicro_midrange_core/rst 1 0
run
force -freeze sim:/picmicro_midrange_core/rst 0 0
