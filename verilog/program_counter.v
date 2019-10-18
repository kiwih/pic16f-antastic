module program_counter (
	input wire clk,
	input wire rst,
	
	input wire pc_incr_en, //set pc = pc + 1
	
	input wire [10:0] pc_j_addr, //used for call and goto and similar
	input wire pc_j_en, //set pc = pclath[4:3],load_pc_dest //TODO: work from here
	input wire pc_j_and_push_en,
	input wire pc_j_by_pop_en,
	
	output wire [12:0] pc_out,
	
	input wire pclath_wr_en,
	input wire [4:0] pclath_in,
	output wire [4:0] pclath_out,
	
	input wire pcl_wr_en,
	input wire [7:0] pcl_in
);

reg [4:0] pclath = 5'd0;
reg [12:0] pc = 13'd0;

wire [12:0] pc_plus_1 = pc + 13'd1;
wire [12:0] pc_tos;

always @(posedge clk) begin
	if(rst) begin
		pclath <= 5'd0;
		pc <= 13'd0;
	end else begin
		if(pc_j_en | pc_j_and_push_en) begin
			pc <= {pclath[4:3], pc_j_addr};
		end else if(pc_j_by_pop_en) begin
			pc <= pc_tos;
		end else begin
			if(pc_incr_en) begin
				pc <= pc_plus_1;
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
end

assign pc_out = pc;
assign pclath_out = pc[12:8];

hardware_stack hs(
	.clk(clk),
	.rst(rst),
	.pop(pc_j_by_pop_en),
	.push(pc_j_and_push_en),
	.in(pc), //while you'd think this would be pc+1, by the time we emit push the pc has already been loaded with pc+1
	.out(pc_tos)
);


endmodule
