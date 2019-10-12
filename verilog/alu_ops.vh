
localparam alu_op_zero	= 4'h0; //output a zero (used during reset scenarios)
localparam alu_op_add 	= 4'h1; //add W and f or add literal and W
localparam alu_op_and 	= 4'h2; //AND W and f or AND literal and W
localparam alu_op_clr	= 4'h3; //clr F or clr W
localparam alu_op_com	= 4'h4; //complement F
localparam alu_op_dec	= 4'h5; //decrement F
localparam alu_op_inc	= 4'h6; //increment F
localparam alu_op_or		= 4'h7; //inclusive OR W with f
localparam alu_op_passlf= 4'h8; //pass thru f (used for movf)
localparam alu_op_passw = 4'h9; //pass through w (used for movwf)
localparam alu_op_rlf   = 4'hA; //rotate f left thru carry
localparam alu_op_rrf   = 4'hB; //rotate f right thru carry
localparam alu_op_sub	= 4'hC; //subtract W from f or subtract W from literal
localparam alu_op_swapf = 4'hD; //swap nibbles in f
localparam alu_op_xor	= 4'hE; //xor W and f or XOR literal and W

