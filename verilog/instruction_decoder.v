module instruction_decoder(
	input wire clk,
	input wire rst,
	
	input wire [13:0] instr_current,
	
	output reg alu_sel_l,
	output reg [3:0] alu_op,
	output reg alu_status_wr_en,
	
	output reg instr_rd_en,
	
	output reg incr_pc_en,
	
	output reg w_reg_wr_en
);

`include "isa.vh"
`include "alu_ops.vh"

//takes 4 clock cycles to execute a command
//

//most instructions take 4 clock cycles
//1: instruction decode cycle or forced nop
//2: instruction read or nop
//3: process data
//4: instruction write cycle or nop

//imagine that the instruction memory is just full of NOPs
//cycle n-1: NOP loaded into instruction memory register
//cycle n: nothing
//cycle n+1: nothing
//cycle n+2: nothing
//cycle n+3: PC = PC+1

//branch instructions take 8

reg [1:0] q_count = 2'd0; //used to count the 4 clock cycles of executing a command

always @(posedge clk) begin
	if(rst)
		q_count = 2'd0;
	else
		q_count = q_count + 2'd1;
end

always @* begin
	alu_sel_l <= 1'd0;
	alu_op <= 4'd0;
	alu_status_wr_en <= 1'd0;
	instr_rd_en <= 1'd0;
	incr_pc_en <= 1'd0;
	w_reg_wr_en <= 1'd0;
	
	casez(instr_current)
	
	isa_nop: begin
		case(q_count)
		//2'd0:
		//2'd1:
		2'd2:
			incr_pc_en <= 1'd1;
		2'd3:
			instr_rd_en <= 1'd1;
		endcase
	end
	
	isa_movlw: begin
		case(q_count)
		2'd0: begin
			alu_sel_l <= 1'd1;
			alu_op <= alu_op_passlf;
			w_reg_wr_en <= 1'd1;
		end
		//2'd1:
		2'd2:
			incr_pc_en <= 1'd1;
		2'd3:
			instr_rd_en <= 1'd1;
		
		
		endcase
	end
	
	
	endcase



end


endmodule
