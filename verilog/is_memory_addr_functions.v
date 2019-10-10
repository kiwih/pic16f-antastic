function automatic is_memory_addr_indirect_addr_sel(
	input wire [12:0] memory_addr
);

is_memory_addr_indirect_addr_sel= (memory_addr[7:0] == 8'd0);
endfunction

	
//	output wire indirect_addr_sel,
//	
//	output wire tmr0_sel,
//	output wire pcl_sel,
//	output wire status_sel,
//	output wire fsr_sel,
//	output wire porta_sel,
//	output wire portb_sel,
//	
//	output wire pclath_sel,
//	output wire intcon_sel,
//	output wire pir1_sel,
//	
//	output wire option_sel,
//	output wire trisa_sel,
//	output wire trisb_sel,
//	
//	output wire pie1_sel,
//	
//	output wire pcon_sel,
	
