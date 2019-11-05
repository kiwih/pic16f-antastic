//this implementation will mimic the 16f628aon the de2-115
//note it won't be _entirely_ faithful, as I will make the UART permanently have its own pins
//also there are no ADCs
`default_nettype none

module pic16fantastic_on_de2_115(
	input wire CLOCK_50,
	
	input wire [3:0] KEY,
	input wire [7:0] SW,
	
	output wire [7:0] LEDG,
	
	inout wire LCD_DATA[7:0],
	inout wire LCD_RS,
	inout wire LCD_RW,
	inout wire LCD_E,
	
	input wire UART_RXD,
	output wire UART_TXD
);

`include "peripheral_memory_map.vh"

wire clk = CLOCK_50;
wire clk_wdt = 1'b0;
wire rst_ext = ~KEY[3];

wire rst_peripherals;

wire [8:0] extern_peripherals_addr;
wire extern_peripherals_wr_en;
wire [7:0] extern_peripherals_data_in;
reg [7:0] extern_peripherals_data_out;
wire [7:0] extern_peripherals_interrupt_strobes;

wire [7:0] porta_tris;
wire [7:0] porta_port;
reg porta_tris_wr_en;
reg porta_port_wr_en;

picmicro_midrange_core core(
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
	porta_tris_wr_en <= 1'd0;
	porta_port_wr_en <= 1'd0;
	extern_peripherals_data_out <= 8'd0;
	casez(extern_peripherals_addr)
		trisa_address: begin
			porta_tris_wr_en <= extern_peripherals_wr_en;
			extern_peripherals_data_out <= porta_tris;
		end
		porta_address: begin
			porta_port_wr_en <= extern_peripherals_wr_en;
			extern_peripherals_data_out <= porta_port;
		end
	endcase
end

bidir_port porta(
	.clk(clk),
	.rst(rst_peripherals),
	
	.physical_in(SW[7:0]), //external values (inputs)
	
	.tris(porta_tris), //external output enable (if true, set as input for that position)
	.port(porta_port), 
	
	.tris_in(extern_peripherals_data_in),
	.tris_wr_en(porta_tris_wr_en),
	.port_in(extern_peripherals_data_in),
	.port_wr_en(porta_port_wr_en)
);

assign LEDG[7:0] = porta_port;


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

