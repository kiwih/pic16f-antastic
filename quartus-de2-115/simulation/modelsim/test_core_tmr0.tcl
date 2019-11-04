vlog -reportprogress 300 -work work ../../../verilog/testbenches/test_picmicro_midrange_core_tmr0.sv
vsim work.test_picmicro_midrange_core_tmr0
add wave -position insertpoint sim:/test_picmicro_midrange_core_tmr0/core/*
add wave -position insertpoint sim:/test_picmicro_midrange_core_tmr0/core/control/*
onfinish stop
run -all