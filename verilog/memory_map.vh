`ifndef memory_map_vh
`define memory_map_vh
localparam is_indirect_address = 9'bxxx000000;

localparam tmr0_address 	= 		9'bx00000001;
localparam option_address 	=		9'bx10000001;
localparam pcl_address 		=		9'bxx0000010;
localparam status_address 	=		9'bxx0000011;
localparam fsr_address 		=		9'bxx0000100;

localparam pclath_address	=		9'bxx0001010;
localparam intcon_address	=		9'bxx0001011;

localparam portb_address	=		9'bx00000110;
localparam trisb_address	=		9'bx10000110;

localparam porta_address	=		9'h05;
localparam trisa_address	=		9'h85;



`endif