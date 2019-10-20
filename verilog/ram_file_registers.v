module ram_file_registers (
	input wire clk,
	input wire rst,
	input wire [8:0] addr,
	input wire wr_en,
	input wire [7:0] data_in,
	output reg [7:0] data_out,
	
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
	output reg extern_peripherals_en,
	input wire [7:0] extern_peripherals_out

);

`include "memory_map.vh"

reg [8:0] addr_reg = 9'd0;

reg gpRegistersA_wr_en;
reg [7:0] gpRegistersA_out;
wire [8:0] gpRegistersA_addr = addr_reg - gpRegistersAStart;
reg [7:0] gpRegistersA [gpRegistersALength - 1:0];

reg gpRegistersB_wr_en;
reg [7:0] gpRegistersB_out;
wire [8:0] gpRegistersB_addr = addr_reg - gpRegistersBStart;
reg [7:0] gpRegistersB [gpRegistersBLength - 1:0];

reg gpRegistersC_wr_en;
reg [7:0] gpRegistersC_out;
wire [8:0] gpRegistersC_addr = addr_reg - gpRegistersCStart;
reg [7:0] gpRegistersC [gpRegistersCLength - 1:0];

reg gpRegistersShared_wr_en;
reg [7:0] gpRegistersShared_out;
wire [8:0] gpRegistersShared_addr = {2'b0, addr_reg[6:0]} - gpRegistersSharedStart;
reg [7:0] gpRegistersShared [gpRegistersSharedLength - 1:0];

always @(posedge clk)
	addr_reg = addr;
	
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

always @* begin
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
	extern_peripherals_en <= 1'b0;
	gpRegistersA_wr_en <= 1'b0;
	gpRegistersB_wr_en <= 1'b0;
	gpRegistersC_wr_en <= 1'b0;
	gpRegistersShared_wr_en <= 1'b0;
	
	//indirect address handled at earlier stage
	casez(addr_reg)
	tmr0_address: begin
		tmr0_reg_wr_en <= wr_en;
		data_out <= tmr0_reg_val;
	end
	
	option_address: begin
		option_reg_wr_en <= wr_en;
		data_out <= option_reg_val;
	end
	
	pcl_address: begin
		pcl_reg_wr_en <= wr_en;
		data_out <= pcl_reg_val;
	end
	
	pclath_address: begin
		pclath_reg_wr_en <= wr_en;
		data_out <= pclath_reg_val;
	end
	
	status_address: begin
		status_reg_wr_en <= wr_en;
		data_out <= status_reg_val;
	end
	
	fsr_address: begin
		fsr_reg_wr_en <= wr_en;
		data_out <= fsr_reg_val;
	end
	
	intcon_address: begin
		intcon_reg_wr_en <= wr_en;
		data_out <= intcon_reg_val;
	end
	
	pir1_address: begin
		pir1_reg_wr_en <= wr_en;
		data_out <= pir1_reg_val;
	end
	
	pie1_address: begin
		pie1_reg_wr_en <= wr_en;
		data_out <= pie1_reg_val;
	end	
	
	default: 
		if(addr_reg >= gpRegistersAStart && addr_reg < gpRegistersAStart + gpRegistersALength) begin
			gpRegistersA_wr_en <= wr_en;
			data_out <= gpRegistersA_out;
		end else if(addr_reg >= gpRegistersBStart && addr_reg < gpRegistersBStart + gpRegistersBLength) begin
			gpRegistersB_wr_en <= wr_en;
			data_out <= gpRegistersB_out;
		end else if(addr_reg >= gpRegistersCStart && addr_reg < gpRegistersCStart + gpRegistersCLength) begin
			gpRegistersC_wr_en <= wr_en;
			data_out <= gpRegistersC_out;
		end else if({3'b0, addr_reg[6:0]} >= gpRegistersSharedStart && {3'b0, addr_reg[6:0]} < gpRegistersSharedStart + gpRegistersCLength) begin
			gpRegistersShared_wr_en <= wr_en;
			data_out <= gpRegistersShared_out;
		end else begin
			data_out <= extern_peripherals_out;
		end
	endcase
end

endmodule

