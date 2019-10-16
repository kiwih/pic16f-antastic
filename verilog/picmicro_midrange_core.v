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
wire instr_flush;
wire [13:0] instr_current;
wire [6:0] instr_f; 	//in an instruction with an f, this will contain the f slice
assign instr_f = instr_current[6:0];
//wire instr_d;			//in an instruction with a d, this will contain the d slice
//assign instr_d = instr_current[7];
wire [2:0] instr_b;	//in an instruction with a b, this will contain the b slice
assign instr_b = instr_current[9:7];
wire [7:0] instr_l;  //in an instruction with a l, this will contain the l slice
assign instr_l = instr_current[7:0];
wire [10:0] instr_j; //in an instruction with a destination, this will contain the destination slice (we say "j" is the "jump" address for goto, call, etc)
assign instr_j = instr_current[10:0];

wire [8:0] regfile_addr;
wire [7:0] regfile_data_out;
wire pcl_reg_wr_en;
wire [7:0] pcl_reg_out;
wire pclath_reg_wr_en;
wire [7:0] pclath_reg_out;
wire status_reg_wr_en;
wire [7:0] status_reg_out;
wire fsr_reg_wr_en;
wire [7:0] fsr_reg_out;
wire intcon_reg_wr_en;
wire [7:0] intcon_reg_out;
wire pir1_reg_wr_en;
wire [7:0] pir1_reg_out;
wire pie1_reg_wr_en;
wire [7:0] pie1_reg_out;
wire pcon_reg_wr_en;
wire [7:0] pcon_reg_out;

wire [12:0] pc_out;
wire pc_incr_en;
wire pc_j_en;

wire status_irp;
wire [1:0] status_rp;
wire status_n_to;
wire status_n_pd;
wire status_z;
wire status_dc;
wire status_c;

wire [7:0] w_reg_out;

wire alu_sel_l; //if 1, the alu selects l, if 0, it selects f
wire alu_d_wr_en;	//write info for alu operations will pass thru ALU
wire alu_d;			//d sets the destination, either w (if 0) or f (if 1)
wire alu_out_f_wr_en;
wire alu_out_w_wr_en;
wire [3:0] alu_op;
wire [7:0] alu_out;
wire alu_status_wr_en;
wire alu_out_z;
wire alu_out_z_wr_en;
wire alu_out_dc;
wire alu_out_dc_wr_en;
wire alu_out_c;
wire alu_out_c_wr_en;
wire alu_bit_test_res;

//includes a register to save the current output(and only update upon rd_en)
program_memory progmem (
	.clk(clk),
	.rst(rst),
	.rd_en(instr_rd_en),
	.flush(instr_flush),
	.addr(pc_out),
	.instr(instr_current)
);

ram_file_address_mux #(
	.IS_INDIRECT_ADDRESS(is_indirect_address)
) rfam (
	.status_rp(status_rp),
	.opcode_address(instr_f), 
	.status_irp(status_irp),
	.fsr(fsr_reg_out),
	.ram_file_address(regfile_addr)
);

assign extern_peripherals_addr = regfile_addr;
assign extern_peripherals_data_in = alu_out;

ram_file_registers regfile (
	.clk(clk),
	.rst(rst),
	.addr(regfile_addr),
	.wr_en(alu_out_f_wr_en),
	.data_in(alu_out),
	.data_out(regfile_data_out),
	
	//pc inputs to ram_file_registers so they can be muxed on to the regfile_data_out
	.pcl_reg_wr_en(pcl_reg_wr_en),
	.pcl_reg_val(pcl_reg_out), 
	.pclath_reg_wr_en(pclath_reg_wr_en),
	.pclath_reg_val(pclath_reg_out),
	
	.status_reg_wr_en(status_reg_wr_en),
	.status_reg_val(status_reg_out),
	
	.fsr_reg_wr_en(fsr_reg_wr_en),
	.fsr_reg_val(fsr_reg_out),		
	.intcon_reg_wr_en(intcon_reg_wr_en),
	.intcon_reg_val(intcon_reg_out),
	
	.pir1_reg_wr_en(pir1_reg_wr_en),
	.pir1_reg_val(pir1_reg_out),
	
	.pie1_reg_wr_en(pie1_reg_wr_en),
	.pie1_reg_val(pie1_reg_out),
	
	.pcon_reg_wr_en(pcon_reg_wr_en),
	.pcon_reg_val(pcon_reg_out),
	
	.extern_peripherals_out(extern_peripherals_data_out) //when the regfile_addr points at something non-core we'll attempt to load it externally
);

program_counter pc(
	.clk(clk),
	.rst(rst),
	.pc_out(pc_out),
	
	.pc_j_addr(instr_j),
	.pc_j_en(pc_j_en),
	
	.pclath_wr_en(pclath_reg_wr_en),
	.pclath_in(alu_out[4:0]),
	.pcl_wr_en(pcl_reg_wr_en),
	.pcl_in(alu_out),
	
	.pc_incr_en(pc_incr_en)
);

status_register streg (
	.clk(clk),
	.rst(rst),
	.status_wr(status_reg_wr_en),
	.status_reg_in(alu_out),
	.status_reg_out(status_reg_out), 
	.irp(status_irp),       	
	.rp(status_rp),  
	.n_to(status_n_to),			
	.n_pd(status_n_pd),	
	
	.z(status_z),		
	.z_wr_en(alu_out_z_wr_en),
	.z_in(alu_out_z),
	
	.dc(status_dc),
	.dc_wr_en(alu_out_dc_wr_en),
	.dc_in(alu_out_dc),
	
	.c(status_c),
	.c_wr_en(alu_out_c_wr_en),
	.c_in(alu_out_c)
);

generic_register fsrreg(
	.clk(clk),
	.rst(rst),
	.wr_en(fsr_reg_wr_en),
	.d(alu_out), 
	.q(fsr_reg_out)
);

generic_register intconreg(
	.clk(clk),
	.rst(rst),
	.wr_en(intcon_reg_wr_en),
	.d(alu_out), 
	.q(intcon_reg_out)
);

generic_register pir1reg(
	.clk(clk),
	.rst(rst),
	.wr_en(pir1_reg_wr_en),
	.d(alu_out), 
	.q(pir1_reg_out)
);

generic_register pie1reg(
	.clk(clk),
	.rst(rst),
	.wr_en(pie1_reg_wr_en),
	.d(alu_out), 
	.q(pie1_reg_out)
);

generic_register pconreg(
	.clk(clk),
	.rst(rst),
	.wr_en(pcon_reg_wr_en),
	.d(alu_out), 
	.q(pcon_reg_out)
);
	
instruction_decoder control(
	.clk(clk),
	.rst(rst),
	
	.instr_current(instr_current),
	
	.alu_op(alu_op),
	.alu_sel_l(alu_sel_l),
	.alu_d(alu_d),
	.alu_status_wr_en(alu_status_wr_en),
//	.alu_bit_test_res(alu_bit_test_res),
	.alu_d_wr_en(alu_d_wr_en),	//write info for alu operations will pass thru ALU
	
	.instr_rd_en(instr_rd_en),
	.instr_flush(instr_flush),
	
	.pc_incr_en(pc_incr_en),
	.pc_j_en(pc_j_en),
	
	.status_z(status_z)

	
);

generic_register w(
	.clk(clk),
	.rst(rst),
	.wr_en(alu_out_w_wr_en),
	.d(alu_out),
	.q(w_reg_out)
);

alu a( //TODO: add a bit test field
	.op_w(w_reg_out),  
	.op_lf(alu_sel_l ? instr_l : regfile_data_out), 
	.op(alu_op),
	
	.alu_d_wr_en(alu_d_wr_en),	//write info for alu operations will pass thru ALU
	.alu_d(alu_d),				//d sets the destination, either w (if 0) or f (if 1)
	
	.alu_out_w_wr_en(alu_out_w_wr_en),
	.alu_out_f_wr_en(alu_out_f_wr_en),
	
	.alu_status_wr_en(alu_status_wr_en),
	
	.alu_c_in(status_c),
	
	.alu_out(alu_out),
	.alu_out_z(alu_out_z),
	.alu_out_z_wr_en(alu_out_z_wr_en),
	.alu_out_dc(alu_out_dc),
	.alu_out_dc_wr_en(alu_out_dc_wr_en),
	.alu_out_c(alu_out_c),
	.alu_out_c_wr_en(alu_out_c_wr_en),
	
	.alu_b_in(instr_b),
	.alu_bit_test_res(alu_bit_test_res)

);
endmodule
