module tmr0wdt(
	input wire clk, 			//the normal clock, Fosc
	input wire clkout,		//the normal clockout, Fosc/4
	input wire clk_t0cki,	//the external tmr0 clock, T0CKI
	input wire t0cs,			//trm0 clock source select bit, 1 = transition on t0cki, 0 = transition on clkout
	input wire t0se,			//tmr0 source edge select bit, 1 = high-to-low transition on T0CKI, 0 = low-to-high
	input wire clk_wdt,		//the watchdog timer clock (usually independent)
	input wire rst,			//reset all counters
	
	input wire wdt_en,		//enable the watchdog timer, 1=yes
	input wire psa,			//psa bit chooses the purpose of the internal prescaler, 1=wdt postscaler, 0=tmr0 prescaler
	input wire [2:0] ps,		//ps chooses scaling of prescaler
	
	input wire tmr0_reg_wr_en,
	input wire [7:0] tmr0_reg_in, //used for reading/writing contents of tmr0
	output wire [7:0] tmr0_reg_out,
	
	input wire wdt_clr,		//clear the watchdog timer
	
	output reg tmr0if_set_en,	//set flag bit T0IF on tmr0 overflow
	output reg wdt_timeout		//set if wdt overflows

);

reg [7:0] wdt_reg = 8'd0;  //counter for wdt
reg wdt_ovf = 1'd0;
reg [7:0] tmr0_reg = 8'd0; //counter for tmr0
assign tmr0_reg_out = tmr0_reg;

reg tmr0_upcount_in;

//wdt_ovf may have arbitrary width, but it will be synchronised by
//the reset logic
always @(posedge clk_wdt) begin
	if(wdt_reg == 8'hff) begin
		wdt_ovf <= 1'd1;
	end else begin
		wdt_ovf <= 1'd0;
	end
	wdt_reg <= wdt_reg + 8'd1;
end

//wire ext_clk = clk_t0cki;
//reg ext_clk_prev = 1'd0;
//reg ext_clk_edge;
//
//always @(posedge clkout)
//	ext_clk_prev <= ext_clk;
//	
//always @* begin
//	if(t0se) //high to low
//		ext_clk_edge <= ext_clk_prev & !ext_clk;
//	else //low to high
//		ext_clk_edge <= !ext_clk_prev & ext_clk;
//end

always @* begin
	if(t0cs) begin
		tmr0_upcount_in = clk_t0cki ^ t0se;
	end else begin
		tmr0_upcount_in = !clkout;
	end
end

reg pres_in;
wire pres_out;

always @* begin
	if(psa)
		pres_in = wdt_ovf;
	else
		pres_in = tmr0_upcount_in;
end

reg pres_clr;
always @* begin
	if(psa)
		pres_clr = rst | wdt_clr;
	else
		pres_clr = rst | (tmr0_reg_wr_en & tmr0_reg_in == 8'd0);
end

//reg pres_clk;
//always @* begin
//	if(psa)
//		pres_clk = clk_wdt;
//	else
//		pres_clk = clkout;
//end

generic_prescaler wdt_post_tmr0_pre(
	//.clk(clk),
	.rst(pres_clr),
	.prescaler_sel_in(ps),
	.cnt(pres_in),
	.ovf(pres_out)
);

//wdt output
always @* begin
	if(psa)
		wdt_timeout <= pres_out;
	else
		wdt_timeout <= wdt_ovf;
end

//the implementation of the sync module in the documentation block diagram is very odd and confusing
//I struggled to get the timing characteristics correct when clocking it at clkout
//Therefore, I have diverged from the documentation's block diagram and instead built something that operates to the
//textual description

reg tmr0_cnt_en_in_prev = 1'd0;
reg tmr0_cnt_en_in = 1'd0;
reg tmr0_cnt_en = 1'd0;

always @(posedge clk) begin
	tmr0_cnt_en_in_prev = tmr0_cnt_en_in;
	if(psa)
		tmr0_cnt_en_in = tmr0_upcount_in;
	else
		tmr0_cnt_en_in = pres_out;
	tmr0_cnt_en = !tmr0_cnt_en_in_prev & tmr0_cnt_en_in;
end

//
//reg tmr0_cnt_en_prev = 1'd0;
//wire tmr0_cnt_en_strobe;
//always @(posedge clk)
//	tmr0_cnt_en_prev <= tmr0_cnt_en;

//wire tmr0_cnt_en = 1'd1;

//assign tmr0_cnt_en_strobe = !	tmr0_cnt_en_prev & tmr0_cnt_en;
//tmr0
always @(posedge clk) begin
	tmr0if_set_en <= 1'd0;
	if(rst)
		tmr0_reg <= 8'd0;
	else if(tmr0_reg_wr_en)
		tmr0_reg <= tmr0_reg_in;
	else if(tmr0_cnt_en) begin
		if(tmr0_reg == 8'hff) begin
			tmr0if_set_en <= 1'd1;
		end
		tmr0_reg <= tmr0_reg + 8'd1;
	end
end
endmodule
