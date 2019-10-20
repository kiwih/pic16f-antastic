module tmr0wdt(
	input wire clkout,		//the normal clockout, Fosc/4
	input wire clk_t0cki,	//the external tmr0 clock, T0CKI
	input wire t0cs,			//trm0 clock source select bit, 1 = transition on t0cki, 0 = transition on clkout
	input wire t0se,			//tmr0 source edge select bit, 1 = high-to-low transition on T0CKI, 0 = low-to-high
	input wire clk_wdt,		//the watchdog timer clock (usually independent)
	input wire rst,			//reset all counters
	
	input wire wdt_en,		//enable the watchdog timer, 1=yes
	input wire psa,			//psa bit chooses the purpose of the internal prescaler, 1=wdt postscaler, 0=tmr0 prescaler
	input wire [2:0] ps,		//ps chooses scaling of prescaler
	
	input wire [7:0] tmr0_reg_in, //used for reading/writing contents of tmr0
	output reg [7:0] tmr0_reg_out,
	
	input wire wdt_clr,		//clear the watchdog timer
	
	output reg tmr0if_set_en,	//set flag bit T0IF on tmr0 overflow
	output reg wdt_timeout		//set if wdt overflows

);



endmodule
