`default_nettype none

module picmicro_midrange_core(
	input wire clk,
	input wire rst,
	
	output wire [8:0] extern_peripherals_addr,
	output wire [7:0] extern_peripherals_data_in,
	input wire [7:0] extern_peripherals_data_out
);

//most instructions take 4 clock cycles
//1: instruction decode cycle or forced nop
//2: instruction read or nop
//3: process data
//4: instruction write cycle or nop

//branch instructions take 8

//

`include "memory_map.vh"

wire instr_rd_en;
wire [13:0] instr_current;
wire [6:0] instr_f; 	//in an instruction with an f, this will contain the f slice
assign instr_f = instr_current[6:0];
wire instr_d;			//in an instruction with a d, this will contain the d slice
assign instr_d = instr_current[7];
wire [2:0] instr_b;	//in an instruction with a b, this will contain the b slice
assign instr_b = instr_current[9:7];
wire [7:0] instr_k;  //in an instruction with a k, this will contain the k slice
assign instr_k = instr_current[7:0];

wire [7:0] core_registers_out; 	//this is based on a whole load of muxes from our core register set (e.g. status, fsr, etc)
											//select lines are based on the current regfile_addr

wire regfile_wr_en;
wire [8:0] regfile_addr;
wire [7:0] regfile_data_in;
wire [7:0] regfile_data_out;

wire [12:0] pc_out;
wire incr_pc_en;

wire status_wr;
wire [7:0] status_reg_in;
wire [7:0] status_reg_out;
wire status_irp;
wire [1:0] status_rp;
wire status_n_to;
wire status_n_pd;
wire status_z;
wire status_dc;
wire status_c;

wire [7:0] alu_out;

wire fsr_wr_en;
wire [7:0] fsr_out;

//includes a register to save the current output(and only update upon rd_en)
program_memory progmem (
	.clk(clk),
	.rd_en(instr_rd_en),
	.addr(pc_out),
	.instr(instr_current)
);

ram_file_address_mux #(
	.IS_INDIRECT_ADDRESS(is_indirect_address)
) rfam (
	.status_rp(status_rp),
	.opcode_address(0), //todo
	.status_irp(status_irp),
	.fsr(fsr_out),
	.ram_file_address(regfile_addr)
);

ram_file_registers regfile (
	.clk(clk),
	.addr(regfile_addr),
	.wr_en(regfile_wr_en),
	.data_in(regfile_data_in),
	.data_out(regfile_data_out),
	
	//other sources of data
	.core_registers_out(core_registers_out),				  //when the regfile_addr points at an internal register (e.g. STATUS) we'll need to load from them instead
	.extern_peripherals_out(extern_peripherals_data_out) //when the regfile_addr points at something non-core we'll attempt to load it externally
);

status_register streg (
	.clk(clk),
	.rst(rst),
	.status_wr(status_wr),
	.status_reg_in(status_reg_in),
	.status_reg_out(status_reg_out), 
	.irp(status_irp),       	
	.rp(status_rp),  
	.n_to(status_n_to),			
	.n_pd(status_n_pd),			
	.z(status_z),				
	.dc(status_dc),			
	.c(status_c)				
);

generic_register fsrreg(
	.clk(clk),
	.rst(rst),
	.wr_en(fsr_wr_en),
	.d(0), //todo
	.q(fsr_out)
);

program_counter pc(
	.clk(clk),
	.rst(rst),
	.pc_out(pc_out),
	.pclath_wr_en(regfile_addr == pclath_address & regfile_wr_en),
	.pclath_in(alu_out[4:0]),
	.pcl_wr_en(regfile_addr == pcl_address & regfile_wr_en),
	.pcl_in(alu_out),
	.incr_pc_en(incr_pc_en),
);


	
instruction_decoder control(
	.clk(clk),
	
	.instr_current(instr_current),
	
	.instr_rd_en(instr_rd_en),
	
	.incr_pc_en(incr_pc_en),


);

alu a(
	

);
endmodule
