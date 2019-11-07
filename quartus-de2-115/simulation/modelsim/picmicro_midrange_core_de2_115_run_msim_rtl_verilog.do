transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/peripherals/uart {/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/peripherals/uart/uart.v}
vlog -vlog01compat -work work +incdir+/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/peripherals/uart {/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/peripherals/uart/uart_spbrg.v}

