module program_counter (
	input wire clk,
	input wire rst,
	
	input wire incr_pc_en,
	output wire [12:0] pc_out,
	
	input wire pclath_wr_en,
	input wire [4:0] pclath_in,
	output wire [4:0] pclath_out,
	
	input wire pcl_wr_en,
	input wire [7:0] pcl_in
);

reg [4:0] pclath = 5'd0;
reg [12:0] pc = 13'd0;

always @(posedge clk) begin
	if(rst) 
		pclath <= 5'd0;
		pc <= 13'd0;
	else begin
		if(incr_pc_en) begin
			pc <= pc + 13'd1;
		end 
		if(pclath_wr_en) begin
			pclath <= pclath_in;
		end 
		if(pcl_wr_en) begin
			pc[12:8] <= pclath;
			pc[7:0] <= pcl_in;
		end
	end
end

assign pc_out = pc;
assign pclath_out = pc[12:8];

endmodule
