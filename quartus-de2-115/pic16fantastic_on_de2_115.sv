//this implementation will mimic the 16f628aon the de2-115
//note it won't be _entirely_ faithful, as I will make the UART permanently have its own pins
//also there are no ADCs
`default_nettype none

module pic16fantastic_on_de2_115 #(
	parameter PROGRAM_FILE_NAME = "lcd.mem"
) (
	input wire CLOCK_50,
	
	input wire [3:0] KEY,
	input wire [7:0] SW,
	
	output wire [7:0] LEDG,
	
	output wire [7:0] LCD_DATA,
	output wire LCD_RS,
	output wire LCD_RW,
	output wire LCD_EN,
	
	output wire [7:0] LEDR,
	
	input wire UART_RXD,
	output wire UART_TXD
);

`include "peripheral_memory_map.vh"

wire clk = CLOCK_50;
wire clk_wdt = 1'b0;
wire rst_ext = ~KEY[3];

wire rst_peripherals;

//wire LCD_SPARE;
//wire [7:0] LCD_BUNDLE = {LCD_E, LCD_RW, LCD_SPARE, LCD_RS, LCD_DATA[3:0]};

wire [8:0] extern_peripherals_addr;
wire extern_peripherals_wr_en;
wire [7:0] extern_peripherals_data_in;
reg [7:0] extern_peripherals_data_out;
wire [7:0] extern_peripherals_interrupt_strobes;

wire [7:0] porta_tris;
wire [7:0] porta_port;
reg porta_tris_wr_en;
reg porta_port_wr_en;

wire [7:0] portb_tris;
wire [7:0] portb_port;
reg portb_tris_wr_en;
reg portb_port_wr_en;

picmicro_midrange_core #(
	.PROGRAM_FILE_NAME(PROGRAM_FILE_NAME)
) core (
	.clk(clk),
	.clk_wdt(clk_wdt),
	.rst_ext(rst_ext),
	.rst_peripherals(rst_peripherals),
	
	.extern_peripherals_addr(extern_peripherals_addr),
	.extern_peripherals_wr_en(extern_peripherals_wr_en),
	.extern_peripherals_data_in(extern_peripherals_data_in),
	.extern_peripherals_data_out(extern_peripherals_data_out),
	
	.extern_peripherals_interrupt_strobes(8'd0)
);

always @* begin
	extern_peripherals_data_out <= 8'd0;
	
	porta_tris_wr_en <= 1'd0;
	porta_port_wr_en <= 1'd0;
	
	portb_tris_wr_en <= 1'd0;
	portb_port_wr_en <= 1'd0;
	
	casez(extern_peripherals_addr)
		trisa_address: begin
			porta_tris_wr_en <= extern_peripherals_wr_en;
			extern_peripherals_data_out <= porta_tris;
		end
		porta_address: begin
			porta_port_wr_en <= extern_peripherals_wr_en;
			extern_peripherals_data_out <= porta_port;
		end
		trisb_address: begin
			portb_tris_wr_en <= extern_peripherals_wr_en;
			extern_peripherals_data_out <= portb_tris;
		end
		portb_address: begin
			portb_port_wr_en <= extern_peripherals_wr_en;
			extern_peripherals_data_out <= portb_port;
		end
	endcase
end

fake_bidir_port porta(
	.clk(clk),
	.rst(rst_peripherals),
	
	.physical_in(SW[7:0]), //external values (inputs)
	.physical_out(LEDG[7:0]),
	
	.tris(porta_tris), //external output enable (if true, set as input for that position)
	.port(porta_port), 
	
	.tris_in(extern_peripherals_data_in),
	.tris_wr_en(porta_tris_wr_en),
	.port_in(extern_peripherals_data_in),
	.port_wr_en(porta_port_wr_en)
);

wire [7:0] portb_phy_in;
reg [7:0] portb_phy_out;
wire [7:0] portb_phy_contr = portb_tris;

fake_bidir_port portb(
	.clk(clk),
	.rst(rst_peripherals),
	
	.physical_in(portb_phy_in),
	.physical_out(portb_phy_out),
	
	.tris(portb_tris),
	.port(portb_port),
	
	.tris_in(extern_peripherals_data_in),
	.tris_wr_en(portb_tris_wr_en),
	.port_in(extern_peripherals_data_in),
	.port_wr_en(portb_port_wr_en)
);

//assign LCD_DATA[0] = portb_phy_contr[0] ? 1'bz : portb_phy_out[0];
//assign LCD_DATA[1] = portb_phy_contr[1] ? 1'bz : portb_phy_out[1];
//assign LCD_DATA[2] = portb_phy_contr[2] ? 1'bz : portb_phy_out[2];
//assign LCD_DATA[3] = portb_phy_contr[3] ? 1'bz : portb_phy_out[3];
//assign LCD_RS		 = portb_phy_contr[4] ? 1'bz : portb_phy_out[4];
//assign LCD_RW		 = portb_phy_contr[6] ? 1'bz : portb_phy_out[6];
//assign LCD_EN		 = portb_phy_contr[7] ? 1'bz : portb_phy_out[7];

assign LCD_DATA[7:4] = portb_phy_out[3:0];
assign LCD_DATA[3:0] = 4'h0;

assign LCD_RS		 = portb_phy_out[4];
assign LCD_RW		 = portb_phy_out[6];
assign LCD_EN		 = portb_phy_out[7];

assign LEDR[7:0] = portb_phy_out[7:0];


always @(posedge clk) 
	portb_phy_in <= portb_phy_out;
//portb_phy_in <= {LCD_E, LCD_RW, 1'b0, LCD_RS, LCD_DATA[3:0]};

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

