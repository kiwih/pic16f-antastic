module alu (
	input wire [7:0] op_w,  //this is always the w register
	input wire [7:0] op_lf, //this is either a literal or a regfile register f
	input wire [3:0] op,
	
	input wire alu_d_wr_en,	//write status for alu operations will pass thru ALU
	input wire alu_d,			//d sets the destination, either w (if 0) or f (if 1)
	
	input wire alu_status_wr_en,
	
	input wire alu_c_in,		//carry bit from the status register
	
	output reg alu_out_w_wr_en,
	output reg alu_out_f_wr_en,
	
	output reg [7:0] alu_out,
	output reg alu_out_z_wr_en,
	output reg alu_out_z,
	output reg alu_out_dc,
	output reg alu_out_dc_wr_en,
	output reg alu_out_c,
	output reg alu_out_c_wr_en,
	
	input wire [2:0] alu_b_in,
	output reg alu_bit_test_res
);

`include "alu_ops.vh"

reg [5:0] temp_add_low;
reg [8:0] temp_add;

always @(op_w, op_lf, op, alu_d_wr_en, alu_d, alu_status_wr_en, alu_c_in, alu_b_in) begin
	//default behaviour for ALU out
	alu_out_w_wr_en <= 1'b0;
	alu_out_f_wr_en <= 1'b0;
	if(!alu_d)
		alu_out_w_wr_en <= alu_d_wr_en;
	else //alu_d
		alu_out_f_wr_en <= alu_d_wr_en;
		
	alu_bit_test_res <= 1'd0;

	alu_out = 8'h0;
	alu_out_z_wr_en <= 1'b0;
	alu_out_z <= 1'b0;
	alu_out_dc <= 1'b0;
	alu_out_dc_wr_en <= 1'b0;
	alu_out_c <= 1'b0;
	alu_out_c_wr_en <= 1'b0;
	temp_add = 9'd0;
	temp_add_low = 5'd0;
	
	case(op)
		alu_op_add: begin //add W and f or add literal and W
			alu_out_z_wr_en <= alu_status_wr_en;
			alu_out_dc_wr_en <= alu_status_wr_en;
			alu_out_c_wr_en <= alu_status_wr_en;
			
			temp_add = op_w + op_lf;
			temp_add_low = op_w[3:0] + op_lf[3:0];
			
			alu_out_c <= temp_add[8];
			alu_out_dc <= temp_add_low[4];
			
			alu_out = temp_add[7:0];
			
			if(alu_out == 8'h0) 
				alu_out_z <= 1'b1;
				
		end
		
		alu_op_and: begin //AND W and f or AND literal and W
			alu_out_z_wr_en <= alu_status_wr_en;
			alu_out = op_w & op_lf;
			
			if(alu_out == 8'h0) 
				alu_out_z <= 1'b1;
		end
		
		alu_op_zero: begin //clr F or clr W
			alu_out = 8'h0;
			alu_out_z <= 1'b1;
			alu_out_z_wr_en <= alu_status_wr_en;
		end
		
		alu_op_com: begin //complement F
			alu_out_z_wr_en <= alu_status_wr_en;
			alu_out = ~op_lf;
			
			if(alu_out == 8'h0) 
				alu_out_z <= 1'b1;
		end
		
		alu_op_dec: begin //decrement F
			alu_out_z_wr_en <= alu_status_wr_en;
			alu_out = op_lf - 1'd1;
			
			if(alu_out == 8'h0) 
				alu_out_z <= 1'b1;
		end
		
		alu_op_inc: begin //increment F
			alu_out_z_wr_en <= alu_status_wr_en;
			alu_out = op_lf + 1'd1;
			
			if(alu_out == 8'h0) 
				alu_out_z <= 1'b1;
		end
		
		alu_op_or: begin //inclusive OR W with f
			alu_out_z_wr_en <= alu_status_wr_en;
			alu_out = op_w | op_lf;
			
			if(alu_out == 8'h0) 
				alu_out_z <= 1'b1;
		end
		
		alu_op_passlf: begin //pass thru f (used for movf)
			alu_out_z_wr_en <= alu_status_wr_en;
			alu_out = op_lf;
			
			if(alu_out == 8'h0) 
				alu_out_z <= 1'b1;
		end
		alu_op_passw: begin //pass through w (used for movwf)
			alu_out_z_wr_en <= alu_status_wr_en;
			alu_out = op_w;
			
			if(alu_out == 8'h0) 
				alu_out_z <= 1'b1;
		end
		alu_op_rlf: begin //rotate f left thru carry
			alu_out_c_wr_en <= alu_status_wr_en;
			
			temp_add = {op_lf, alu_c_in};
			alu_out_c <= temp_add[8];
			
			alu_out = temp_add[7:0];
		end
		alu_op_rrf: begin //rotate f right thru carry
			alu_out_c_wr_en <= alu_status_wr_en;
			
			temp_add = {alu_c_in, op_lf};
			alu_out_c <= temp_add[0];
			
			alu_out = temp_add[8:1];
		end
		
		alu_op_sub: begin //subtract W from f or subtract W from literal
			alu_out_z_wr_en <= alu_status_wr_en;
			alu_out_dc_wr_en <= alu_status_wr_en;
			alu_out_c_wr_en <= alu_status_wr_en;
			
			temp_add = op_lf - op_w;
			temp_add_low = op_lf[3:0] - op_w[3:0];
			
			alu_out_c <= ~temp_add[8];
			alu_out_dc <= ~temp_add_low[4];
			
			alu_out = temp_add[7:0];
			
			if(alu_out == 8'h0) 
				alu_out_z <= 1'b1;
		
		end
		
		alu_op_swapf: begin //swap nibbles in f
			alu_out = {op_lf[3:0], op_lf[7:4]};
		end
		
		alu_op_xor: begin //xor W and f or XOR literal and W
			alu_out_z_wr_en <= alu_status_wr_en;
			alu_out = op_w ^ op_lf;
			
			if(alu_out == 8'h0) 
				alu_out_z <= 1'b1;		
		end
		
		alu_op_bs: begin
			alu_out_w_wr_en <= 1'b0;
			alu_out_f_wr_en <= alu_d_wr_en;
			
			alu_out <= op_lf | 1'b1 << alu_b_in;
			
			if(op_lf[alu_b_in]) 
				alu_bit_test_res <= 1'b1;
			
			//if(alu_d_wr_en)			
			//	alu_out[alu_b_in] <= 1'b1;
				
		end
		
		alu_op_bc: begin
			alu_out_w_wr_en <= 1'b0;
			alu_out_f_wr_en <= alu_d_wr_en;
			
			alu_out <= op_lf & ~(1'b1 << alu_b_in);
			
			if(!op_lf[alu_b_in]) 
				alu_bit_test_res <= 1'b1;
			
//			if(alu_d_wr_en)
//				alu_out[alu_b_in] <= 1'b0;
		end
		
		default: begin
			alu_out = 8'h0;
		end
	endcase

end


endmodule
