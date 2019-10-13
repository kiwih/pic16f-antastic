module instruction_decoder(
	input wire clk,
	input wire rst,
	
	input wire [13:0] instr_current,
	
	output reg alu_sel_l,
	output reg [3:0] alu_op,
	output reg alu_status_wr_en,
	
	output reg instr_rd_en,
	output reg instr_flush,
	
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

//reg two_cycle_instruction = 1'b0; //used when configuring a two-cycle instruction

reg stall = 1'b0;
reg set_stall;
reg clr_stall;

reg [1:0] q_count = 2'd0; //used to count the 4 clock cycles of executing a command

always @(posedge clk) begin
	if(rst)
		q_count = 2'd0;
	else
		q_count = q_count + 2'd1;
end

always @(posedge clk) begin
	if(rst | clr_stall) begin
		stall = 1'b0;
	end else if (set_stall) begin
		stall = 1'b1;
	end
end

always @* begin
	alu_sel_l <= 1'd0;
	alu_op <= 4'd0;
	alu_status_wr_en <= 1'd0;
	instr_rd_en <= 1'd0;
	instr_flush <= 1'd0;
	incr_pc_en <= 1'd0;
	w_reg_wr_en <= 1'd0;
	set_stall <= 1'd0;
	clr_stall <= 1'd0;
	
	casez(instr_current)
	
	isa_nop: begin
		case(q_count)
		
		//2'd1:
		//2'd2:
		//2'd3:
		
		2'd3: begin
			incr_pc_en <= 1'd1;
			instr_rd_en <= 1'd1;
		end
			
		endcase
	end
	
	isa_movlw: begin
		case(q_count)
		
		2'd1: begin
			alu_sel_l <= 1'd1;
			alu_op <= alu_op_passlf;
			w_reg_wr_en <= 1'd1;
		end
		//2'd2:
			//
		//2'd3:
		
		2'd3: begin
			instr_rd_en <= 1'd1;
			incr_pc_en <= 1'd1;
		end
		endcase
	end
		
	isa_goto: begin
		case(q_count):
		
		//2'd1:
		
		//2'd2:
		
		2'd3: begin
			instr_flush <= 1'd1;
			load_pc_en <= 1'd1;
		end
		endcase
	end
//	
	
	endcase



end


endmodule
