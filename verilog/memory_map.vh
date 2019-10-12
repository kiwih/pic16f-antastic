
localparam is_indirect_address = 9'bzzz000000;

localparam gpRegistersAStart 	 = 9'h20;
localparam gpRegistersALength  = 80;

localparam gpRegistersBStart 	 = 9'hA0;
localparam gpRegistersBLength	 = 80;

localparam gpRegistersCStart	 = 9'h120;
localparam gpRegistersCLength	 = 80; //48 for 16f628a, 80 for 16f648a

localparam gpRegistersSharedStart = 9'bzz1110000;
localparam gpRegistersSharedLength = 16;

localparam tmr0_address 	= 		9'bz00000001;
localparam option_address 	=		9'bz10000001;
localparam pcl_address 		=		9'bzz0000010;
localparam status_address 	=		9'bzz0000011;
localparam fsr_address 		=		9'bzz0000100;

localparam pclath_address	=		9'bzz0001010;
localparam intcon_address	=		9'bzz0001011;

localparam pir1_address		=		9'h0C;
localparam pie1_address		= 		9'h8C;

localparam pcon_address		=		9'h8E;

localparam portb_address	=		9'bz00000110;
localparam trisb_address	=		9'bz10000110;

localparam porta_address	=		9'h05;
localparam trisa_address	=		9'h85;



