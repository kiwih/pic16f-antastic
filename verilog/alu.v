module alu (
	input [7:0] op_w,  //this is always the w register
	input [7:0] op_lf, //this is either a literal or a regfile register f
	input [2:0] op,
	output [7:0] alu_out,
	output alu_out_z,
	output alu_out_dc,
	output alu_out_c,
	
	output alu_bit_test_res
);




endmodule
