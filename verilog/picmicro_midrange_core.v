`default_nettype none

module picmicro_midrange_core(
	input wire clk,
	input wire rst
);

//most instructions take 4 clock cycles
//1: instruction decode cycle or forced nop
//2: instruction read or nop
//3: process data
//4: instruction write cycle or nop

//branch instructions take 8

//

wire instr_rd_en;
wire [13:0] instr_current;

wire regfile_wr_en;
wire [8:0] regfile_addr;
wire [7:0] regfile_data_in;
wire [7:0] regfile_data_out;

wire [12:0] pc_out;

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


wire fsr_wr_en;
wire [7:0] fsr_out;

//includes a register to save the current output(and only update upon rd_en)
program_memory progmem (
	.clk(clk),
	.rd_en(instr_rd_en),
	.addr(pc_out),
	.instr(instr_current)
);

ram_file_address_mux rfam(
	.mode_indirect(is_memory_addr_indirect_addr_sel(13'd0)), //todo
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
	.data_out(regfile_data_out)
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

generic_register pclath(
	.clk(clk),
	.rst(rst),
);
	
memory_map_signals mmap(
	
);
endmodule
