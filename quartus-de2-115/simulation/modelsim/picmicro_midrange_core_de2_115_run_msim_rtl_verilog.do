transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core {/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core/tmr0wdt.v}
vlog -vlog01compat -work work +incdir+/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core {/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core/status_register.v}
vlog -vlog01compat -work work +incdir+/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core {/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core/resetmanager.v}
vlog -vlog01compat -work work +incdir+/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core {/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core/ram_file_address_mux.v}
vlog -vlog01compat -work work +incdir+/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core {/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core/program_memory.v}
vlog -vlog01compat -work work +incdir+/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core {/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core/program_counter.v}
vlog -vlog01compat -work work +incdir+/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core {/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core/peripheral_interrupt_register.v}
vlog -vlog01compat -work work +incdir+/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core {/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core/hardware_stack.v}
vlog -vlog01compat -work work +incdir+/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core {/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core/generic_register.v}
vlog -vlog01compat -work work +incdir+/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core {/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core/generic_prescaler.v}
vlog -vlog01compat -work work +incdir+/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core {/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core/core_interrupt_register.v}
vlog -vlog01compat -work work +incdir+/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core {/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core/ram_file_registers.v}
vlog -vlog01compat -work work +incdir+/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core {/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core/picmicro_midrange_core.v}
vlog -vlog01compat -work work +incdir+/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core {/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core/instruction_decoder.v}
vlog -vlog01compat -work work +incdir+/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core {/home/hammond/Documents/quartus_projs/picmicro-midrange-core-hdl/verilog/core/alu.v}

