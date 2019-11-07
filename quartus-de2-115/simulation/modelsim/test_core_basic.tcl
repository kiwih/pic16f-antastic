vlog -reportprogress 300 -work work ../../../verilog/core/testbenches/test_picmicro_midrange_core_basic_instructions.sv
vsim work.test_picmicro_midrange_core_basic_instructions
add wave -position insertpoint sim:/test_picmicro_midrange_core_basic_instructions/core/*
add wave -position insertpoint sim:/test_picmicro_midrange_core_basic_instructions/core/regfile/*
add wave -position insertpoint sim:/test_picmicro_midrange_core_basic_instructions/core/control/*
onfinish stop
run -all