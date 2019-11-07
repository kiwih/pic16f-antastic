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
	
	inout wire [7:0] LCD_DATA,
	inout wire LCD_RS,
	inout wire LCD_RW,
	inout wire LCD_EN,
	
	output wire [7:0] LEDR,
	
	input wire UART_RXD,
	output wire UART_TXD
);

wire clk = CLOCK_50;
wire clk_wdt = 1'b0;
wire rst_ext = ~KEY[3];

wire rst_peripherals;

wire [8:0] extern_peripherals_addr;
wire extern_peripherals_wr_en;
wire [7:0] extern_peripherals_data_in;
wire [7:0] extern_peripherals_data_out;
wire [7:0] extern_peripherals_interrupt_strobes;

wire [7:0] porta_tris;
wire [7:0] porta_port;
wire porta_tris_wr_en;
wire porta_port_wr_en;

wire [7:0] portb_tris;
wire [7:0] portb_port;
wire portb_tris_wr_en;
wire portb_port_wr_en;

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

pic16fantastic_ext_periph_mux ext_periph_mux(
	.extern_peripherals_addr(extern_peripherals_addr),
	.extern_peripherals_wr_en(extern_peripherals_wr_en),
	
	.extern_peripherals_data_out(extern_peripherals_data_out),

	.porta_tris(porta_tris),
	.porta_port(porta_port),
	.porta_tris_wr_en(porta_tris_wr_en),
	.porta_port_wr_en(porta_port_wr_en),

	.portb_tris(portb_tris),
	.portb_port(portb_port),
	.portb_tris_wr_en(portb_tris_wr_en),
	.portb_port_wr_en(portb_port_wr_en)
);


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

reg [7:0] portb_phy_in;
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

assign LCD_DATA[3:0] = 4'h0;
assign LCD_DATA[4] = portb_phy_contr[0] ? 1'bz : portb_phy_out[0];
assign LCD_DATA[5] = portb_phy_contr[1] ? 1'bz : portb_phy_out[1];
assign LCD_DATA[6] = portb_phy_contr[2] ? 1'bz : portb_phy_out[2];
assign LCD_DATA[7] = portb_phy_contr[3] ? 1'bz : portb_phy_out[3];
assign LCD_RS		 = portb_phy_contr[4] ? 1'bz : portb_phy_out[4];
assign LCD_RW		 = portb_phy_contr[6] ? 1'bz : portb_phy_out[6];
assign LCD_EN		 = portb_phy_contr[7] ? 1'bz : portb_phy_out[7];

assign LEDR[7:0] = portb_phy_out[7:0];

always @(posedge clk) 
	portb_phy_in <= {LCD_EN, LCD_RW, 1'b0, LCD_RS, LCD_DATA[3:0]};

endmodule

module pic16fantastic_ext_periph_mux(
	input wire [8:0] extern_peripherals_addr,
	input wire extern_peripherals_wr_en,
	
	output reg [7:0] extern_peripherals_data_out,

	input wire [7:0] porta_tris,
	input wire [7:0] porta_port,
	output reg porta_tris_wr_en,
	output reg porta_port_wr_en,

	input wire [7:0] portb_tris,
	input wire [7:0] portb_port,
	output reg portb_tris_wr_en,
	output reg portb_port_wr_en
);

`include "peripheral_memory_map.vh"

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

endmodule
