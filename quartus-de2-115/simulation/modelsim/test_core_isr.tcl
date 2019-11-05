vlog -reportprogress 300 -work work ../../../verilog/core/testbenches/test_picmicro_midrange_core_isr.sv
vsim work.test_picmicro_midrange_core_isr
add wave -position insertpoint sim:/test_picmicro_midrange_core_isr/core/*
add wave -position insertpoint sim:/test_picmicro_midrange_core_isr/core/control/*
add wave -position insertpoint sim:/test_picmicro_midrange_core_isr/core/pc/hs/*
onfinish stop
run -all