transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/home/hammond/quartus_projs/picmicro-midrange-core-hdl/verilog {/home/hammond/quartus_projs/picmicro-midrange-core-hdl/verilog/status_register.v}
vlog -vlog01compat -work work +incdir+/home/hammond/quartus_projs/picmicro-midrange-core-hdl/verilog {/home/hammond/quartus_projs/picmicro-midrange-core-hdl/verilog/ram_file_address_mux.v}
vlog -vlog01compat -work work +incdir+/home/hammond/quartus_projs/picmicro-midrange-core-hdl/verilog {/home/hammond/quartus_projs/picmicro-midrange-core-hdl/verilog/generic_register.v}
vlog -vlog01compat -work work +incdir+/home/hammond/quartus_projs/picmicro-midrange-core-hdl/verilog {/home/hammond/quartus_projs/picmicro-midrange-core-hdl/verilog/program_counter.v}
vlog -vlog01compat -work work +incdir+/home/hammond/quartus_projs/picmicro-midrange-core-hdl/verilog {/home/hammond/quartus_projs/picmicro-midrange-core-hdl/verilog/picmicro_midrange_core.v}
vlog -vlog01compat -work work +incdir+/home/hammond/quartus_projs/picmicro-midrange-core-hdl/verilog {/home/hammond/quartus_projs/picmicro-midrange-core-hdl/verilog/program_memory.v}
vlog -vlog01compat -work work +incdir+/home/hammond/quartus_projs/picmicro-midrange-core-hdl/verilog {/home/hammond/quartus_projs/picmicro-midrange-core-hdl/verilog/ram_file_registers.v}
vlog -vlog01compat -work work +incdir+/home/hammond/quartus_projs/picmicro-midrange-core-hdl/verilog {/home/hammond/quartus_projs/picmicro-midrange-core-hdl/verilog/instruction_decoder.v}
vlog -vlog01compat -work work +incdir+/home/hammond/quartus_projs/picmicro-midrange-core-hdl/verilog {/home/hammond/quartus_projs/picmicro-midrange-core-hdl/verilog/alu.v}

