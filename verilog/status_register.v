module status_register(
	input wire clk,
	input wire rst,
	input wire status_wr,
	input wire [7:0] status_reg_in,
	
	output wire [7:0] status_reg_out, //note that this is made up of the bits below in order
	
	output wire irp,       	//register bank select bit (used for indirect addressing)
									//1 = Bank 2, 3 (100h-1FFh)
									//2 = Bank 0, 1 ( 00h- FFh)
	
	output wire [1:0] rp,  	//register bank select bits (used fordirect addressing)
									//00 = Bank 0   ( 00h- 7Fh)
									//01 = Bank 1   ( 80h- FFh)
									//10 = Bank 2   (100h-17Fh)
									//11 = Bank 3   (180h-1FFh)
	
	input wire n_to_wr_en,
	input wire n_to_in,
	output wire n_to,			//not Time Out bit (read only)
									//1 = After power-up, CLRWDT instruction or SLEEP instruction
									//0 = a WDT time out occurred
	
	input wire n_pd_wr_en,
	input wire n_pd_in,	
	output wire n_pd,			//not Power-down bit (read only)
									//1 = After power-up or by the CLRWDT instruction
									//0 = By execution of the SLEEP instruction
	
	input wire z_wr_en,
	input wire z_in,
	output wire z,				//Zero bit
									//1 = the result of an arithmetic or logic operation is zero
									//0 = the result of an arithmetic or logic operation is not zero
	
	input wire dc_wr_en,
	input wire dc_in,
	output wire dc,			//Digit Carry (not Borrow) bit
									//1 = A carry-out from the 4th low order bit of the result occurred
									//0 No carry-out from the 4th low order bit of the result
	
	input wire c_wr_en,
	input wire c_in,
	output wire c				//Carry (not Borrow) bit
									//1 = A carry-out from the MSB of the result occurred
									//0 = No carry-out from the MSB of the result occurred
		
	
);

reg [7:0] internalStatus;

//todo: finish this properly with regard to PD and TO bits
always @(posedge clk) begin
	if(rst)
		internalStatus <= 8'b00011000;
	else begin
		if(status_wr) begin
			internalStatus[7:5] <= status_reg_in[7:5];
			internalStatus[2:0] <= status_reg_in[2:0];
		end
		if(n_to_wr_en)
			internalStatus[4] <= n_to_in;
		if(n_pd_wr_en)
			internalStatus[3] <= n_pd_in;
		if(z_wr_en)
			internalStatus[2] <= z_in;
		if(dc_wr_en)
			internalStatus[1] <= dc_in;
		if(c_wr_en)
			internalStatus[0] <= c_in;
	end
end
		
assign status_reg_out = internalStatus;

assign irp = internalStatus[7];
assign rp = internalStatus[6:5];
assign n_to = internalStatus[4];
assign n_pd = internalStatus[3];
assign z = internalStatus[2];
assign dc = internalStatus[1];
assign c = internalStatus[0];

endmodule
