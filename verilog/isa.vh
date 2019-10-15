//byte-oriented file register operations														//implemented	//tested
localparam isa_addwf	=	14'b00_0111_zzzz_zzzz; //Add W and f							Yes				Yes
localparam isa_andwf	=	14'b00_0101_zzzz_zzzz; //AND W with f							Yes				Yes
localparam isa_clrf	=	14'b00_0001_1zzz_zzzz; //Clear f									Yes				Yes
localparam isa_clrw	= 	14'b00_0001_0zzz_zzzz; //Clear W									Yes				Yes
localparam isa_comf	=	14'b00_1001_zzzz_zzzz; //Complement f							Yes				Yes
localparam isa_decf	=	14'b00_0011_zzzz_zzzz; //Decrement f							Yes				Yes
localparam isa_decfsz=	14'b00_1011_zzzz_zzzz; //Decrement f, Skip if 0				Yes				Yes
localparam isa_incf	=	14'b00_1010_zzzz_zzzz; //Increment f							Yes				Yes
localparam isa_incfsz=	14'b00_1111_zzzz_zzzz; //Increment f, Skip if 0				Yes				Yes
localparam isa_iorwf =	14'b00_0100_zzzz_zzzz; //Inclusive OR W with f				Yes				Yes
localparam isa_movf	=	14'b00_1000_zzzz_zzzz; //Move f									Yes				Yes
localparam isa_movwf =	14'b00_0000_1zzz_zzzz; //Move W to f							Yes				Yes
localparam isa_rlf	=	14'b00_1101_zzzz_zzzz; //Rotate Left f through Carry
localparam isa_rrf	=	14'b00_1100_zzzz_zzzz; //Rotate Right f through Carry
localparam isa_subwf	=	14'b00_0010_zzzz_zzzz; //Subtract W from f
localparam isa_swapf=	14'b00_1110_zzzz_zzzz; //Swap nibbles in f
localparam isa_xorwf =	14'b00_0110_zzzz_zzzz; //Exclusive OR W with f

//bit-oriented file register operations
localparam isa_bcf	=	14'b01_00zz_zzzz_zzzz; //Bit Clear f
localparam isa_bsf	=	14'b01_01zz_zzzz_zzzz; //Bit Set f
localparam isa_btfsc	=	14'b01_10zz_zzzz_zzzz; //Bit Test f, Skip if Clear
localparam isa_btfss =	14'b01_11zz_zzzz_zzzz; //Bit Test f, Skip if Set

//literal operations
localparam isa_addlw =	14'b11_111z_zzzz_zzzz; //Add literal and W
localparam isa_andlw	=	14'b11_1001_zzzz_zzzz; //AND literal with W
localparam isa_iorlw =	14'b11_1000_zzzz_zzzz; //Inclusive Or literal with W
localparam isa_movlw	=	14'b11_00zz_zzzz_zzzz; //Move literal to W
localparam isa_retlw	=	14'b11_01zz_zzzz_zzzz; //Return with literal in W
localparam isa_sublw	=	14'b11_110z_zzzz_zzzz; //Subtract W from literal
localparam isa_xorlw	=	14'b11_1010_zzzz_zzzz; //Exclusive OR literal with W

//control operations
localparam isa_nop	=	14'b00_0000_0zz0_0000; //No operation							Yes				Yes
localparam isa_call	=	14'b10_0zzz_zzzz_zzzz; //Call subroutine
localparam isa_clrwdt=	14'b00_0000_0110_0100; //Clear Watchdog Timer
localparam isa_goto	=	14'b10_1zzz_zzzz_zzzz; //Go to address
localparam isa_retfie=	14'b00_0000_0000_1001; //Return from interrupt
localparam isa_return=	14'b00_0000_0000_1000; //Retrun from Subroutine
localparam isa_sleep	=	14'b00_0000_0110_0011; //Go into standby mode
