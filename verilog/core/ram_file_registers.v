module ram_file_registers (
	input wire clk,
	input wire rst,
	input wire [8:0] addr,
	input wire rd_en,
	input wire wr_en,
	input wire [7:0] data_in,
	output reg [7:0] data_out, //can be thought of as "f"
	
	//pc inputs to ram_file_registers so they can be muxed on to the regfile_data_out
	output reg pcl_reg_wr_en,
	input wire [7:0] pcl_reg_val,
	
	output reg pclath_reg_wr_en,
	input wire [7:0] pclath_reg_val,
	
	//status register input to ram_file_registers so it can be muxed onto the regfile_data_out
	output reg status_reg_wr_en,
	input wire [7:0] status_reg_val,
	
	//core register outputs
	//when the regfile_addr points at an internal register (e.g. STATUS) we'll need to load from them instead
	output reg tmr0_reg_wr_en,
	input wire [7:0] tmr0_reg_val,
	
	output reg option_reg_wr_en,
	input wire [7:0] option_reg_val,
	
	output reg fsr_reg_wr_en,
	input wire [7:0] fsr_reg_val,

	output reg intcon_reg_wr_en,
	input wire [7:0] intcon_reg_val,
	
	output reg pir1_reg_wr_en,
	input wire [7:0] pir1_reg_val,
	
	output reg pie1_reg_wr_en,
	input wire [7:0] pie1_reg_val,
	
	output reg pcon_reg_wr_en,
	input wire [7:0] pcon_reg_val,
	
	//when the regfile_addr points at something non-core we'll attempt to load it externally
	output reg extern_peripherals_rd_en,
	output reg extern_peripherals_wr_en,
	input wire [7:0] extern_peripherals_out

);

`include "memory_map.vh"

reg gpRegistersA_wr_en;
reg [7:0] gpRegistersA_out;
wire [8:0] gpRegistersA_addr = addr - gpRegistersAStart;
reg [7:0] gpRegistersA [gpRegistersALength - 1:0];

reg gpRegistersB_wr_en;
reg [7:0] gpRegistersB_out;
wire [8:0] gpRegistersB_addr = addr - gpRegistersBStart;
reg [7:0] gpRegistersB [gpRegistersBLength - 1:0];

reg gpRegistersC_wr_en;
reg [7:0] gpRegistersC_out;
wire [8:0] gpRegistersC_addr = addr - gpRegistersCStart;
reg [7:0] gpRegistersC [gpRegistersCLength - 1:0];

reg gpRegistersShared_wr_en;
reg [7:0] gpRegistersShared_out;
wire [8:0] gpRegistersShared_addr = {2'b0, addr[6:0]} - gpRegistersSharedStart;
reg [7:0] gpRegistersShared [gpRegistersSharedLength - 1:0];

always @(posedge clk) begin
	if(gpRegistersA_wr_en) begin
		gpRegistersA[gpRegistersA_addr] <= data_in;
	end
	gpRegistersA_out = gpRegistersA[gpRegistersA_addr];
end

always @(posedge clk) begin
	if(gpRegistersB_wr_en) begin
		gpRegistersB[gpRegistersB_addr] <= data_in;
	end
	gpRegistersB_out = gpRegistersB[gpRegistersB_addr];
end

always @(posedge clk) begin
	if(gpRegistersC_wr_en) begin
		gpRegistersC[gpRegistersC_addr] <= data_in;
	end
	gpRegistersC_out = gpRegistersC[gpRegistersC_addr];
end

always @(posedge clk) begin
	if(gpRegistersShared_wr_en) begin
		gpRegistersShared[gpRegistersShared_addr] <= data_in;
	end
	gpRegistersShared_out = gpRegistersShared[gpRegistersShared_addr];
end

reg [7:0] data_out_tmp = 8'd0;

reg rd_en_last = 1'b0;
reg rd_en_laster = 1'b0;

always @(posedge clk)
	if(rst) begin
		rd_en_last <= 1'b0;
		rd_en_laster <= 1'b0;
	end else begin
		rd_en_last <= rd_en;
		rd_en_laster <= rd_en_last;
	end
	
always @(posedge clk)  begin
	if(rd_en_last)
		data_out <= data_out_tmp;
end

always @(*) begin
	tmr0_reg_wr_en <= 1'b0;
	option_reg_wr_en <= 1'b0;
	pcl_reg_wr_en <= 1'b0;
	pclath_reg_wr_en <= 1'b0;
	status_reg_wr_en <= 1'b0;
	fsr_reg_wr_en <= 1'b0;
	intcon_reg_wr_en <= 1'b0;
	pir1_reg_wr_en <= 1'b0;
	pie1_reg_wr_en <= 1'b0;
	pcon_reg_wr_en <= 1'b0;
	extern_peripherals_wr_en <= 1'b0;
	gpRegistersA_wr_en <= 1'b0;
	gpRegistersB_wr_en <= 1'b0;
	gpRegistersC_wr_en <= 1'b0;
	gpRegistersShared_wr_en <= 1'b0;
	data_out_tmp <= 8'd0;
	
	//indirect address handled at earlier stage
	casez(addr)
	tmr0_address: begin
		tmr0_reg_wr_en <= wr_en;
		data_out_tmp <= tmr0_reg_val;
	end
	
	option_address: begin
		option_reg_wr_en <= wr_en;
		data_out_tmp <= option_reg_val;
	end
	
	pcl_address: begin
		pcl_reg_wr_en <= wr_en;
		data_out_tmp <= pcl_reg_val;
	end
	
	pclath_address: begin
		pclath_reg_wr_en <= wr_en;
		data_out_tmp <= pclath_reg_val;
	end
	
	status_address: begin
		status_reg_wr_en <= wr_en;
		data_out_tmp <= status_reg_val;
	end
	
	fsr_address: begin
		fsr_reg_wr_en <= wr_en;
		data_out_tmp <= fsr_reg_val;
	end
	
	intcon_address: begin
		intcon_reg_wr_en <= wr_en;
		data_out_tmp <= intcon_reg_val;
	end
	
	pir1_address: begin
		pir1_reg_wr_en <= wr_en;
		data_out_tmp <= pir1_reg_val;
	end
	
	pie1_address: begin
		pie1_reg_wr_en <= wr_en;
		data_out_tmp <= pie1_reg_val;
	end	
	
	default: 
		if(addr >= gpRegistersAStart && addr < gpRegistersAStart + gpRegistersALength) begin
			gpRegistersA_wr_en <= wr_en;
			data_out_tmp <= gpRegistersA_out;
		end else if(addr >= gpRegistersBStart && addr < gpRegistersBStart + gpRegistersBLength) begin
			gpRegistersB_wr_en <= wr_en;
			data_out_tmp <= gpRegistersB_out;
		end else if(addr >= gpRegistersCStart && addr < gpRegistersCStart + gpRegistersCLength) begin
			gpRegistersC_wr_en <= wr_en;
			data_out_tmp <= gpRegistersC_out;
		end else if({3'b0, addr[6:0]} >= gpRegistersSharedStart && {3'b0, addr[6:0]} < gpRegistersSharedStart + gpRegistersCLength) begin
			gpRegistersShared_wr_en <= wr_en;
			data_out_tmp <= gpRegistersShared_out;
		end else begin
			extern_peripherals_rd_en <= rd_en;
			extern_peripherals_wr_en <= wr_en;
			data_out_tmp <= extern_peripherals_out;
		end
	endcase
end

endmodule

