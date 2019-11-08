vlog -reportprogress 300 -work work ../../../verilog/peripherals/uart/testbenches/test_uart.sv
vsim work.test_uart
add wave -position insertpoint sim:/test_uart/*
add wave -position insertpoint sim:/test_uart/u/*
onfinish stop
run -all