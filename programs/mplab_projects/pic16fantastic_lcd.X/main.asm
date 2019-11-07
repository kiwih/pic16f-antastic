    list p=16f628a 
    include p16f628a.inc
    
; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR

    
; NAMED REGISTERS
    cblock 0x20 ;general purpose registers
	count ;used in looping routines
	count1 ;used in delay routine
	counta ;used in delay routine
	countb ;used in delay routine
	delay_400ns_count; //used in delay_routines
	tmp1 ;temporary storage
	tmp2 ;temporary storage
	tmplcd ;temp store for 4 bit mode
	tmplcd2
	tmr0_isr_counter_l
	tmr0_isr_counter_h
	
    endc

; LABELS    
    
LCD_PORT    Equ	PORTB
LCD_TRIS    Equ	TRISB
LCD_RS	    Equ	0x04			;LCD handshake lines
LCD_RW	    Equ	0x06
LCD_E	    Equ	0x07
	   
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

; TODO ADD INTERRUPTS HERE IF USED
ISR_VECT  CODE	  0x0004
    bcf INTCON, T0IF
    decfsz tmr0_isr_counter_l, f
    retfie
    decfsz tmr0_isr_counter_h, f
    retfie
    comf PORTA, f
    retfie
    
MAIN_PROG CODE                      ; let linker place main program

; text blocks
 
TEXT_NAME
    addwf PCL, f
    retlw ' '
    retlw ' '
    retlw '1'
    retlw '6'
    retlw 'F'
    retlw '-'
    retlw 'a'
    retlw 'n'
    retlw 't'
    retlw 'a'
    retlw 's'
    retlw 't'
    retlw 'i'
    retlw 'c'
    retlw ' '
    retlw ' '
    retlw 0x00
    
TEXT_HELLO_WORLD
    addwf PCL, f
    retlw 'H'
    retlw 'e'
    retlw 'l'
    retlw 'l'
    retlw 'o'
    retlw ' '
    retlw 'w'
    retlw 'o'
    retlw 'r'
    retlw 'l'
    retlw 'd'
    retlw '!'
    retlw ' '
    retlw ':'
    retlw ')'
    retlw ' '
    retlw 0x00
 
; HELPFUL FUNCTIONS
 
CONF_LCD_PORT
    bsf STATUS, RP0 ;change to bank 1
    movlw 0x00	    ; make all pins outputs
    movwf LCD_TRIS
    bcf STATUS, RP0 ;change to bank 0
    return

LCD_PULSE_E ;pulse enable line of LCD high
    call Delay20
    bsf LCD_PORT, LCD_E
    call Delay20
    bcf LCD_PORT, LCD_E
    call Delay20
    retlw 0x00
    
LCD_CMD	;function to send a command (in w register) to LCD
    movwf tmplcd    ;save the argument
    
    ;let's first send the upper nibble
    swapf tmplcd, w	    ;swap the upper 4 bits of arg into low bits of w
    andlw 0x0f		    ;clear top bits of w to set up the lcd tx
    movwf LCD_PORT	    ;transfer data to lcd port
    bcf	LCD_PORT, LCD_RS    ;RS line to 0
    call LCD_PULSE_E
    ;now let's send the lower nibble
    movf tmplcd, w
    andlw 0x0f		    ;clear top bits of w to set up the lcd tx
    movwf LCD_PORT	    ;transfer data to lcd port
    bcf	LCD_PORT, LCD_RS    ;RS line to 0
    call LCD_PULSE_E	    
    
    nop
    retlw 0x00
    
LCD_CLR ;function to send a clear command to LCD
    movlw 0x01
    call LCD_CMD
    retlw 0x00

LCD_CUROFF ;function to set cursor command
    movlw 0x0c
    call LCD_CMD
    retlw 0x00
    
LCD_CURON
    movlw 0x0d
    call LCD_CMD
    retlw 0x00

LCD_LINE1 ;move to 1st row, first column
    movlw 0x80			
    call LCD_CMD
    retlw 0x00

LCD_LINE2 ;move to 2nd row, first column
    movlw 0xc0			
    call LCD_CMD
    retlw 0x00

LCD_LINE1W ;move to 1st row, column W	
    addlw 0x80			
    call LCD_CMD
    retlw 0x00

LCD_LINE2W ;move to 2nd row, column W
    addlw 0xc0			
    call LCD_CMD
    retlw 0x00

LCD_INIT ; initialise the LCD to 4 bit mode, etc
    call Delay255
    call Delay255
    call Delay255
    call Delay255
    
    movlw 0x20		    ; 4 bit mode
    call LCD_CMD
    call Delay255
    call Delay255
    call Delay255
    call Delay255
    
    movlw 0x20		    ; 4 bit mode
    call LCD_CMD
    call Delay255
    call Delay255
    call Delay255
    call Delay255
    
    movlw 0x28		    ; Set display shift
    call LCD_CMD
    call Delay255
    movlw 0x06		    ; Display character mode
    call LCD_CMD
    call Delay255
    movlw 0x0d		    ; Display on/off and cursor command
    call LCD_CMD
    call Delay255
    
    call LCD_CLR	    ; clear display
    retlw 0x00

LCD_CHARD ; function to send an uppercase character to the display
    ;falls througn into next function
    andlw 0x30
LCD_CHAR ; function to send a character to the display
    movwf tmplcd    ;save the argument
    
    ;let's first send the upper nibble
    swapf tmplcd, w	    ;swap the upper 4 bits of arg into low bits of w
    andlw 0x0f		    ;clear top bits of w to set up the lcd tx
    movwf LCD_PORT	    ;transfer data to lcd port
    bsf	LCD_PORT, LCD_RS    ;RS line to 1
    call LCD_PULSE_E
    ;now let's send the lower nibble
    movf tmplcd, w
    andlw 0x0f		    ;clear top bits of w to set up the lcd tx
    movwf LCD_PORT	    ;transfer data to lcd port
    bsf	LCD_PORT, LCD_RS    ;RS line to 1
    call LCD_PULSE_E	  
    
    nop
    retlw 0x00
    
CONF_SW_LED_PORT
    bsf STATUS, RP0 ;change to bank 1
    movlw 0x00	    ;set PORTA to be half input
    movwf TRISA
    bcf STATUS, RP0 ;change to bank 0
    return

Delay255	movlw	0xff		;delay 255 mS
		goto	d0
Delay100	movlw	d'100'		;delay 100mS
		goto	d0
Delay50		movlw	d'50'		;delay 50mS
		goto	d0
Delay20		movlw	d'20'		;delay 20mS
		goto	d0
Delay5		movlw	0x05		;delay 5.000 ms (4 MHz clock)
d0		movwf	count1
d1		movlw	0xC7			;delay 1mS
		movwf	counta
		movlw	0x01
		movwf	countb
Delay_0
		decfsz	counta, f
		goto	$+2
		decfsz	countb, f
		goto	Delay_0

		decfsz	count1	,f
		goto	d1
		retlw	0x00    

; we are running at 50MHz
; each instruction takes 4 cycles if it isn't a branch, so 80ns
; branch instructions take 160ns (2 instruction counts)
; 25 instruction counts would take 2us
;
;		
;		
;		
;DELAY_2US   ; we need 25 instruction counts
;				    ; call DELAY_2US = 2 counts
;				    ; init	     = 2 counts, subtotal 2
;				    ; each value in delay_400ns_count takes 5 cycles (including the zero cycle)
;	movlw 0x03		    ; for 2us delay we need 25 counts, so 4 iterations plus our junk (which needs to take 5 cycles)
;	movwf delay_2us_count	    ; 1 count
;	nop			    ; 1 count
;DELAY_400NS_LOOP		    ; for each loop decrement: 1+4=5 counts				    ; for final loop: 2+2+1=5 counts
;	decfsz delay_2us_count, f   ; 1 count if not zero, 2 counts if zero (and go to nop)
;	goto $+3		    ; 2 counts
;	nop			    ; 1 counts
;	retlw 0x00		    ; 2 counts
;	goto DELAY_400NS_LOOP	    ; 2 counts

START
    call Delay255
    call Delay255
    call Delay255
    call Delay255
    
    bsf INTCON, T0IE
    bsf INTCON, GIE
    
    clrf TMR0
    
    bsf STATUS, RP0 ;change to bank 1
    bcf OPTION_REG, T0CS ;set up timer0
    
    bsf TXSTA, TXEN ;set up UART TX to be 9600 baud and enabled
    bcf TXSTA, BRGH
    movlw 0x50
    movwf SPBRG
    
    bcf STATUS, RP0 ;change to bank 0
    
    clrf PORTA
    clrf PORTB
    
    movlw 0x10
    movwf PORTA
    
    call CONF_LCD_PORT
    call CONF_SW_LED_PORT
    
    movlw 0x20
    movwf PORTA
    
    call LCD_INIT
    call Delay255
    
    call LCD_CUROFF
    
    movwf PORTA
    
    call LCD_LINE1

MESSAGE_NAME
    call LCD_LINE1
    clrf count
MESSAGE_NAME_LOOP
    movf count, w
    call TEXT_NAME ;get a character from the text table
    movwf PORTA
    xorlw 0x00 ;is it a zero?
    btfsc STATUS, Z
    goto MESSAGE_HELLO_WORLD
    call LCD_CHAR
    incf count, f
    goto MESSAGE_NAME_LOOP

MESSAGE_HELLO_WORLD
    call LCD_LINE2
    clrf count
MESSAGE_HELLO_WORLD_LOOP
    movf count, w
    call TEXT_HELLO_WORLD ;get a character from the text table
    movwf PORTA
    xorlw 0x00 ;is it a zero?
    btfsc STATUS, Z
    goto END_LOOP
    call LCD_CHAR
    incf count, f
    goto MESSAGE_HELLO_WORLD_LOOP
    
END_LOOP
    movlw '!'
    movwf TXREG
    GOTO END_LOOP                          ; loop forever

    
    END