module program_memory #(
	parameter ADDR_WIDTH = 13,
	parameter INSTR_WIDTH = 14
) (
	input wire clk,
	input wire rst,
	input wire flush,
	input wire rd_en,
	input wire [ADDR_WIDTH - 1:0] addr,
	output reg [INSTR_WIDTH - 1:0] instr
);

reg [INSTR_WIDTH - 1:0] instrReg;
reg [INSTR_WIDTH - 1:0] instrMemory [2**ADDR_WIDTH - 1:0];

initial begin
	instr = {INSTR_WIDTH{1'b0}};
	`ifdef MODEL_TECH
	  // code for simulation with modelsim
	  `ifdef testcontrol
			$readmemb("testcontrol.prog", instrMemory);
	  `else
			$readmemb("test.prog", instrMemory);
		`endif
	`else
	  // code for synthesis
	  $readmemb("./simulation/modelsim/test.prog", instrMemory);
	`endif
	
//   instrMemory[0] = 14'b00_0000_0000_0000; //nop
//	instrMemory[1] = 14'b11_0000_1010_1011; //movlw 0xAB
//	instrMemory[2] = 14'b00_0000_1010_0000; //movwf 0x20
//	instrMemory[3] = 14'b11_0000_1100_1101; //movlw 0xCD
//	instrMemory[4] = 14'b00_1000_0010_0000; //movf(w) 0x20 
//	instrMemory[5] = 14'b10_1000_0000_0001; //goto 0x001 (the movlw instruction)
//	instrMemory[6] = 14'b11_0000_1110_1111; //movlw 0xEF
end

//TODO: mif

always @(posedge clk)
	instrReg = instrMemory[addr];
		
always @(posedge clk)
	if(rst | flush)
		instr <= {INSTR_WIDTH{1'b0}};
	else if(rd_en)
		instr <= instrReg;
	
		
endmodule

