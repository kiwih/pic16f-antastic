module core_interrupt_register #(
	parameter WIDTH = 8,
	parameter RESET_VALUE = 8'd0
) (
	input wire clk,
	input wire wr_en,
	input wire rst,
	input wire [WIDTH - 1:0] d,
	output reg [WIDTH - 1:0] q,
	
	input wire intcon_gie_clr_en,
	input wire intcon_gie_set_en,
	
	input wire intcon_t0if_set_en,
	
	output wire intcon_gie,
	output wire intcon_peie,
	output wire intcon_t0ie,
	output wire intcon_inte,
	output wire intcon_rbie,
	output wire intcon_t0if,
	output wire intcon_intf,
	output wire intcon_rbif
);

initial q = RESET_VALUE;

always @(posedge clk) begin
	if(rst) begin
		q <= RESET_VALUE;	
	end else begin
		if(wr_en)
			q <= d;
		
		if(intcon_gie_clr_en)
			q[7] = 1'b0;
		else if(intcon_gie_set_en)
			q[7] = 1'b1;
		
		if(intcon_t0if_set_en)
			q[2] = 1'b1;
	end
end

assign intcon_gie 	= q[7];	//global interrupt enable
assign intcon_peie 	= q[6]; //peripheral interrupt enable
assign intcon_t0ie   = q[5];	//tmr0 interrupt enable
assign intcon_inte 	= q[4];	//rb0/int external interrupt enable
assign intcon_rbie 	= q[3];	//rb port change interrupt enable
assign intcon_t0if   = q[2];	//tmr0 interrupt flag
assign intcon_intf 	= q[1];	//rb0/int external interrupt flag
assign intcon_rbif 	= q[0];	//rb port change interrupt flag 

endmodule