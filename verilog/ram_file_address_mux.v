module ram_file_address_mux(
	input wire mode_direct, //if 1, mux uses direct addressing (using opcode)
									//if 0, mux uses indirect addressing (using FSR)
	
	input wire [1:0] status_rp,
	input wire [6:0] opcode_address,
	
	input wire status_irp,
	input wire [7:0] fsr,
	
	output reg ram_file_address
);

always @* begin
	if(mode_direct)
		ram_file_address = {status_rp, opcode_address};
	else
		ram_file_address = {status_irp, fsr};
end

endmodule
