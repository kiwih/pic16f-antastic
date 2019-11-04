vlog -reportprogress 300 -work work ../../../verilog/testbenches/test_picmicro_midrange_core_control_flow.sv
vsim work.test_picmicro_midrange_core_control_flow
add wave -position insertpoint sim:/test_picmicro_midrange_core_control_flow/core/*
add wave -position insertpoint sim:/test_picmicro_midrange_core_control_flow/core/control/*
onfinish stop
run -all