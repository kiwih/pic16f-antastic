vlog -reportprogress 300 -work work ../../../verilog/peripherals/uart/testbenches/test_uart_spbrg.sv
vsim work.test_uart_spbrg
add wave -position insertpoint sim:/test_uart_spbrg/*
add wave -position insertpoint sim:/test_uart_spbrg/spbrg/*
onfinish stop
run -all