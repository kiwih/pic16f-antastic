module pic16f628a_on_de2_115(
	input wire CLOCK_50,
	input wire [3:0] KEY,
	
);

//this implementation will mimic the 16f628a




//PORTA0 = LCD_DATA[0]
//PORTA1 = LCD_DATA[1]
//PORTA2 = LCD_DATA[2]
//PORTA3 = LCD_DATA[3]
//PORTA4 = LCD_RS
//PORTA5 = unused input
//PORTA6 = LCD_RW
//PORTA7 = LCD_E


//PORTA0 = KEY[0], LEDG[0]
//PORTA1 = KEY[1], LEDG[1]
//PORTA2 = KEY[2], LEDG[2]
//PORTA3 = KEY[3], LEDG[3]
//PORTA4 = SW[0], LEDR[0]
//PORTA5 = SW[1], LEDR[1]
//PORTA6 = SW[2], LEDR[2]
//PORTA7 = SW[3], LEDR[3]

//i have demapped the UART so that it is always available on UART_TXD and UART_RXD


endmodule

