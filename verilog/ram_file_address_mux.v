module ram_file_address_mux #(
	parameter IS_INDIRECT_ADDRESS = 9'bxxx000000
) (
	input wire [1:0] status_rp,
	input wire [6:0] opcode_address,
	
	input wire status_irp,
	input wire [7:0] fsr,
	
	output reg [8:0] ram_file_address
);

wire [8:0] combined_address;
assign combined_address = {status_rp, opcode_address};

always @* begin
	if(combined_address == IS_INDIRECT_ADDRESS) 	//if 1, mux uses indirect addressing (using FSR)
																//if 0, mux uses direct addressing (using opcode)
		ram_file_address = {status_irp, fsr};
	else
		ram_file_address = combined_address;
end

endmodule
