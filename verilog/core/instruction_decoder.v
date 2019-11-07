module instruction_decoder(
	input wire clk,
	input wire rst,
	output reg clkout,
	
	input wire interrupt_flag,
	
	input wire [13:0] instr_current,
	
	output reg alu_status_wr_en,
	output reg alu_sel_l,
	output reg [3:0] alu_op,

	output reg f_rd_en,
	output reg f_wr_en,
	output reg w_wr_en,
	
	input wire bit_test_res,
	
	output reg instr_rd_en,
	output reg instr_flush,
	
	output reg pc_incr_en,
	output reg pc_j_en,
	output reg pc_j_and_push_en,
	output reg pc_j_by_pop_en,
	output reg pc_j_to_isr,
	
	output reg wdt_clr,
	
	output reg gie_set_en,
	output reg gie_clr_en,
	
	input wire status_z
);

`include "isa.vh"
`include "alu_ops.vh"

//takes 4 clock cycles to execute a command
//

//most instructions take 4 clock cycles
//1: instruction decode cycle or forced nop, also decodes ram file memory addresses
//2: data read from memory thru mux network or nop 
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

wire alu_d = instr_current[7]; //This is the default case. 0 = W register, 1 = F register

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
	instr_flush <= 1'd0;
	pc_incr_en <= 1'd0;
	pc_j_en <= 1'd0;
	pc_j_and_push_en <= 1'd0;
	pc_j_by_pop_en <= 1'd0;
	pc_j_to_isr <= 1'd0;
	f_rd_en <= 1'd0;
	f_wr_en <= 1'd0;
	w_wr_en <= 1'd0;
	wdt_clr <= 1'd0;
	gie_set_en <= 1'd0;
	gie_clr_en <= 1'd0;
	
	clkout <= 1'd0; //generate clkout, which has frequency Fosc/4 (clk/4)
	if(q_count == 2'd0 | q_count == 2'd1) begin
		clkout <= 1'd1;
	end

	casez(instr_current)
		
		isa_addwf: begin //Add W and f	
			case(q_count)
			2'd0: begin
				f_rd_en <= 1'd1;
			end
			2'd2: begin
				alu_sel_l <= 1'd0;
				alu_op <= alu_op_add;
				alu_status_wr_en <= 1'd1;
				
				if(!alu_d)
					w_wr_en <= 1'd1;
				else //alu_d
					f_wr_en <= 1'd1;
			end		
			2'd3: begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
			endcase
		end
		
		isa_andwf: begin //AND W with f		
			case(q_count)
			2'd0: begin
				f_rd_en <= 1'd1;
			end
			2'd2: begin
				alu_sel_l <= 1'd0;
				alu_op <= alu_op_and;
				alu_status_wr_en <= 1'd1;
				
				if(!alu_d)
					w_wr_en <= 1'd1;
				else //alu_d
					f_wr_en <= 1'd1;
			end		
			2'd3: begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
			endcase
		end
		
		isa_clrf: begin //Clear f		
			case(q_count)
			2'd2: begin
				alu_sel_l <= 1'd0;
				alu_op <= alu_op_zero;
				alu_status_wr_en <= 1'd1;
				
				if(!alu_d)
					w_wr_en <= 1'd1;
				else //alu_d
					f_wr_en <= 1'd1;
			end		
			2'd3: begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
			endcase
		end
		
		isa_clrw: begin //Clear W	
			case(q_count)
			2'd2: begin
				alu_sel_l <= 1'd0;
				alu_op <= alu_op_zero;
				alu_status_wr_en <= 1'd1;
				
				if(!alu_d)
					w_wr_en <= 1'd1;
				else //alu_d
					f_wr_en <= 1'd1;
			end		
			2'd3: begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
			endcase
		end
		
		isa_comf: begin //Complement f
			case(q_count)
			2'd0: begin
				f_rd_en <= 1'd1;
			end
			2'd2: begin
				alu_sel_l <= 1'd0;
				alu_op <= alu_op_com;
				alu_status_wr_en <= 1'd1;
				
				if(!alu_d)
					w_wr_en <= 1'd1;
				else //alu_d
					f_wr_en <= 1'd1;
			end		
			2'd3: begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
			endcase
		end
		
		isa_decf: begin //Decrement f
			case(q_count)
			2'd0: begin
				f_rd_en <= 1'd1;
			end
			2'd2: begin
				alu_sel_l <= 1'd0;
				alu_op <= alu_op_dec;
				alu_status_wr_en <= 1'd1;
				
				if(!alu_d)
					w_wr_en <= 1'd1;
				else //alu_d
					f_wr_en <= 1'd1;
			end		
			2'd3: begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
			endcase
		end
		
		isa_decfsz: begin //Decrement f, Skip if 0	
			case(q_count)
			2'd0: begin
				f_rd_en <= 1'd1;
			end
			2'd2: begin
				alu_sel_l <= 1'd0;
				alu_op <= alu_op_dec;
				alu_status_wr_en <= 1'd1;
				
				if(!alu_d)
					w_wr_en <= 1'd1;
				else //alu_d
					f_wr_en <= 1'd1;
			end		
			2'd3: begin //TODO: Check: what should happen for an interrupt here, exactly? How to deal with skipped instruction? Perhaps it is only delayed on skip
				instr_flush <= status_z;
				instr_rd_en <= ~status_z;
				pc_incr_en <= 1'd1;
			end
			endcase
		end
		
		isa_incf: begin //Increment f	
			case(q_count)
			2'd0: begin
				f_rd_en <= 1'd1;
			end
			2'd2: begin
				alu_sel_l <= 1'd0;
				alu_op <= alu_op_inc;
				alu_status_wr_en <= 1'd1;
				
				if(!alu_d)
					w_wr_en <= 1'd1;
				else //alu_d
					f_wr_en <= 1'd1;
			end		
			2'd3: begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
			endcase
		end
		
		isa_incfsz: begin //Increment f, Skip if 0
			case(q_count)
			2'd0: begin
				f_rd_en <= 1'd1;
			end
			2'd2: begin
				alu_sel_l <= 1'd0;
				alu_op <= alu_op_inc;
				alu_status_wr_en <= 1'd1;
				
				if(!alu_d)
					w_wr_en <= 1'd1;
				else //alu_d
					f_wr_en <= 1'd1;
			end		
			2'd3: begin
				instr_flush <= status_z;
				instr_rd_en <= ~status_z;
				pc_incr_en <= 1'd1;
			end
			endcase
		end
		
		isa_iorwf: begin //Inclusive OR W with f
			case(q_count)
			2'd0: begin
				f_rd_en <= 1'd1;
			end
			2'd2: begin
				alu_sel_l <= 1'd0;
				alu_op <= alu_op_or;
				alu_status_wr_en <= 1'd1;
				
				if(!alu_d)
					w_wr_en <= 1'd1;
				else //alu_d
					f_wr_en <= 1'd1;
			end		
			2'd3: begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
			endcase
		end
		
		isa_movf: begin //Move f
			case(q_count)
			2'd0: begin
				f_rd_en <= 1'd1;
			end
			2'd2: begin
				alu_sel_l <= 1'd0; //pass f, not l
				alu_status_wr_en <= 1'd1; //movf does set status bits
				alu_op <= alu_op_passlf;
				
				if(!alu_d)
					w_wr_en <= 1'd1;
				else //alu_d
					f_wr_en <= 1'd1;
			end		
			2'd3: begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
			endcase
		end
		
		isa_movwf: begin //Move W to f
			case(q_count)
			2'd0: begin
				f_rd_en <= 1'd1;
			end
			2'd2: begin
				alu_op <= alu_op_passw;
				alu_status_wr_en <= 1'd0; //movwf does NOT set status bits
				
				//if(!alu_d)
				//	w_wr_en <= 1'd1;
				//else //alu_d
				f_wr_en <= 1'd1;
			end		
			2'd3: begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
			endcase
		end
		
		isa_rlf: begin //Rotate Left f through Carry
			case(q_count)
			2'd0: begin
				f_rd_en <= 1'd1;
			end
			2'd2: begin
				alu_sel_l <= 1'd0;
				alu_op <= alu_op_rlf;
				alu_status_wr_en <= 1'd1;
				
				if(!alu_d)
					w_wr_en <= 1'd1;
				else //alu_d
					f_wr_en <= 1'd1;
			end		
			2'd3: begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
			endcase
		end
		
		isa_rrf: begin //Rotate Right f through Carry
			case(q_count)
			2'd0: begin
				f_rd_en <= 1'd1;
			end
			2'd2: begin
				alu_sel_l <= 1'd0;
				alu_op <= alu_op_rrf;
				alu_status_wr_en <= 1'd1;
				
				if(!alu_d)
					w_wr_en <= 1'd1;
				else //alu_d
					f_wr_en <= 1'd1;
			end		
			2'd3: begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
			endcase
		end
		
		isa_subwf: begin //Subtract W from f
			case(q_count)
			2'd0: begin
				f_rd_en <= 1'd1;
			end
			2'd2: begin
				alu_sel_l <= 1'd0;
				alu_op <= alu_op_sub;
				alu_status_wr_en <= 1'd1;
				
				if(!alu_d)
					w_wr_en <= 1'd1;
				else //alu_d
					f_wr_en <= 1'd1;
			end		
			2'd3: begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
			endcase	
		end
		
		isa_swapf: begin //Swap nibbles in f
			case(q_count)
			2'd0: begin
				f_rd_en <= 1'd1;
			end
			2'd2: begin
				alu_sel_l <= 1'd0;
				alu_op <= alu_op_swapf;
				alu_status_wr_en <= 1'd0; //swapf does not affect status
				
				if(!alu_d)
					w_wr_en <= 1'd1;
				else //alu_d
					f_wr_en <= 1'd1;
			end		
			2'd3: begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
			endcase	
		end
		
		isa_xorwf: begin //Exclusive OR W with f
			case(q_count)
			2'd0: begin
				f_rd_en <= 1'd1;
			end
			2'd2: begin
				alu_sel_l <= 1'd0;
				alu_op <= alu_op_xor;
				alu_status_wr_en <= 1'd1;
				
				if(!alu_d)
					w_wr_en <= 1'd1;
				else //alu_d
					f_wr_en <= 1'd1;
			end		
			2'd3: begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
			endcase	
		end
		
		//bit-oriented file register operations
		
		isa_bcf: begin //Bit Clear f
			case(q_count)
			2'd0: begin
				f_rd_en <= 1'd1;
			end
			2'd2: begin
				alu_sel_l <= 1'd0;
				alu_op <= alu_op_bc;
				alu_status_wr_en <= 1'd1;
				
				f_wr_en <= 1'd1;
			end		
			2'd3: begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
			endcase	
		end
		
		isa_bsf: begin //Bit Set f
			case(q_count)
			2'd0: begin
				f_rd_en <= 1'd1;
			end
			2'd2: begin
				alu_sel_l <= 1'd0;
				alu_op <= alu_op_bs;
				alu_status_wr_en <= 1'd1;
				
				f_wr_en <= 1'd1;
			end		
			2'd3: begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
			endcase	
		end
		
		isa_btfsc: begin //Bit Test f, Skip if Clear
			case(q_count)
			2'd0: begin
				f_rd_en <= 1'd1;
			end
			2'd2: begin
				alu_sel_l <= 1'd0;
				alu_op <= alu_op_bc;
				alu_status_wr_en <= 1'd0; //we're just testing a bit
			end		
			2'd3: begin
				instr_flush <= bit_test_res;
				instr_rd_en <= ~bit_test_res;
				pc_incr_en <= 1'd1;
			end
			endcase
		
		
		end
		
		isa_btfss: begin //Bit Test f, Skip if Set
			case(q_count)
			2'd0: begin
				f_rd_en <= 1'd1;
			end
			2'd2: begin
				alu_sel_l <= 1'd0;
				alu_op <= alu_op_bs;
				alu_status_wr_en <= 1'd0; //we're just testing a bit
			end		
			2'd3: begin
				instr_flush <= bit_test_res;
				instr_rd_en <= ~bit_test_res;
				pc_incr_en <= 1'd1;
			end
			endcase
		end
		
		//////////////////literal operations
		isa_addlw: begin //Add literal and W
			case(q_count)
			2'd2: begin
				alu_sel_l <= 1'd1;
				alu_op <= alu_op_add;
				w_wr_en <= 1'd1;
				alu_status_wr_en <= 1'd1;
			end		
			2'd3: begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
			endcase
		end
		
		isa_andlw: begin //AND literal with W
			case(q_count)
			2'd2: begin
				alu_sel_l <= 1'd1;
				alu_op <= alu_op_and;
				alu_status_wr_en <= 1'd1;
				w_wr_en <= 1'd1;
			end		
			2'd3: begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
			endcase
		end
		
		isa_iorlw: begin //Inclusive Or literal with W
			case(q_count)
			2'd2: begin
				alu_sel_l <= 1'd1;
				alu_op <= alu_op_or;
				alu_status_wr_en <= 1'd1;
				w_wr_en <= 1'd1;
			end		
			2'd3: begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
			endcase
		end
		
		isa_movlw: begin	//Move literal to W
			case(q_count)
			2'd2: begin
				alu_sel_l <= 1'd1;
				alu_op <= alu_op_passlf;
				w_wr_en <= 1'd1;
			end		
			2'd3: begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
			endcase
		end
		
		isa_retlw: begin	//Return with literal in W
			if(q_count == 2'd2) begin
				alu_sel_l <= 1'd1;
				alu_op <= alu_op_passlf;
				w_wr_en <= 1'd1;
			end else if(q_count == 2'd3) begin
				instr_flush <= 1'd1;
				pc_j_by_pop_en <= 1'd1; 
			end
		end
		
		isa_sublw: begin	//Subtract W from literal
			case(q_count)
			2'd2: begin
				alu_sel_l <= 1'd1;
				alu_op <= alu_op_sub;
				w_wr_en <= 1'd1;
				alu_status_wr_en <= 1'd1;
			end		
			2'd3: begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
			endcase
		end
		
		isa_xorlw: begin	//Exclusive OR literal with W
			case(q_count)
			2'd2: begin
				alu_sel_l <= 1'd1;
				alu_op <= alu_op_xor;
				w_wr_en <= 1'd1;
				alu_status_wr_en <= 1'd1;
			end		
			2'd3: begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
			endcase
		end
		
		///////////////////////////////
		
		isa_nop: begin
			if(q_count == 2'd3) begin
				if(interrupt_flag) begin //(for single cycle instructions) an interrupt has occurred, we detect+deal with it in q=3
					instr_flush <= 1'd1;
					pc_j_to_isr <= 1'd1; 
					gie_clr_en <= 1'd1; //disable interrupts
				end else begin
					instr_rd_en <= 1'd1;
					pc_incr_en <= 1'd1;
				end
			end
		end
		
		isa_call: begin //Call subroutine
			if(q_count == 2'd3) begin
				instr_flush <= 1'd1;
				pc_j_and_push_en <= 1'd1; //the PC will load the j address
			end
		end
		
		//isa_clrwdt //Clear Watchdog Timer
		
		isa_goto: begin
			if(q_count == 2'd3) begin
				instr_flush <= 1'd1;
				pc_j_en <= 1'd1; //the PC will load the j address
			end
		end
		
		isa_retfie: begin //Return from interrupt
			if(q_count == 2'd3) begin
				instr_flush <= 1'd1;
				pc_j_by_pop_en <= 1'd1; 
				gie_set_en <= 1'd1; //reenable interrupts
			end
		end
		
		isa_return: begin	//Retrun from Subroutine
			if(q_count == 2'd3) begin
				instr_flush <= 1'd1;
				pc_j_by_pop_en <= 1'd1; 
			end
		end
		
		//isa_sleep //Go into standby mode
		

			
		
		
	endcase
end


endmodule
