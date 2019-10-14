module instruction_decoder(
	input wire clk,
	input wire rst,
	
	input wire [13:0] instr_current,
	
	output reg alu_status_wr_en,
	output reg alu_sel_l,
	output reg alu_d,
	output reg [3:0] alu_op,
	output reg alu_d_wr_en,
	
	output reg instr_rd_en,
	output reg instr_flush,
	
	output reg pc_incr_en,
	output reg pc_j_en
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
	alu_d <= instr_current[7]; //This is the default case. 0 = W register, 1 = F register
	alu_sel_l <= 1'd0;
	alu_op <= 4'd0;
	alu_d_wr_en <= 1'd0;
	alu_status_wr_en <= 1'd0;
	instr_rd_en <= 1'd0;
	instr_flush <= 1'd0;
	pc_incr_en <= 1'd0;
	pc_j_en <= 1'd0;
	set_stall <= 1'd0;
	clr_stall <= 1'd0;
	
	casez(instr_current)
	isa_addwf: begin
		case(q_count)
		2'd2: begin
			alu_sel_l <= 1'd0;
			alu_op <= alu_op_add;
			alu_status_wr_en <= 1'd1;
			alu_d_wr_en <= 1'd1;
		end		
		2'd3: begin
			instr_rd_en <= 1'd1;
			pc_incr_en <= 1'd1;
		end
		endcase
	end
	
	isa_nop: begin
		if(q_count == 2'd3) begin
			pc_incr_en <= 1'd1;
			instr_rd_en <= 1'd1;
		end
	end
	
	isa_movlw: begin
		case(q_count)
		
		2'd2: begin
			alu_sel_l <= 1'd1;
			alu_d <= 1'd0;
			alu_op <= alu_op_passlf;
			alu_d_wr_en <= 1'd1;
		end		
		2'd3: begin
			instr_rd_en <= 1'd1;
			pc_incr_en <= 1'd1;
		end
		endcase
	end
		
	isa_movwf: begin
		case(q_count)
		2'd2: begin
			alu_op <= alu_op_passw;
			alu_status_wr_en <= 1'd1;
			alu_d_wr_en <= 1'd1;
		end		
		2'd3: begin
			instr_rd_en <= 1'd1;
			pc_incr_en <= 1'd1;
		end
		endcase
	end
	
	isa_movf: begin
		case(q_count)
		2'd2: begin
			alu_sel_l <= 1'd0; //pass f, not l
			alu_op <= alu_op_passlf;
			alu_d_wr_en <= 1'd1;
		end		
		2'd3: begin
			instr_rd_en <= 1'd1;
			pc_incr_en <= 1'd1;
		end
		endcase
	end
		
	isa_goto: begin
		if(q_count == 2'd3) begin
			instr_flush <= 1'd1;
			pc_j_en <= 1'd1; //the PC will load the j address
		end
	end
	
	endcase
end


endmodule
