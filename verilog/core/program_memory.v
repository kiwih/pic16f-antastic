module program_memory #(
	parameter ADDR_WIDTH = 13,
	parameter INSTR_WIDTH = 14,
	parameter PROGRAM_FILE_NAME = "default.mem"
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
	`ifndef MODEL_TECH
		//code for synthesis. Testbenches will override this initialisation.
		$readmemh({"../../programs/", PROGRAM_FILE_NAME}, instrMemory);
	`endif

//alternatively, you can manually specify instructions, e.g.:
// instrMemory[0] = 14'b00_0000_0000_0000; //nop
//	instrMemory[1] = 14'b11_0000_1010_1011; //movlw 0xAB
//	instrMemory[2] = 14'b00_0000_1010_0000; //movwf 0x20
//	instrMemory[3] = 14'b11_0000_1100_1101; //movlw 0xCD
//	instrMemory[4] = 14'b00_1000_0010_0000; //movf(w) 0x20 
//	instrMemory[5] = 14'b10_1000_0000_0001; //goto 0x001 (the movlw instruction)
//	instrMemory[6] = 14'b11_0000_1110_1111; //movlw 0xEF

//	instrMemory[13'h0000] = 14'b10_1000_0001_0000; //reset vector: goto 0010 
//	instrMemory[13'h0001] = 14'b00_0000_0000_0000; //nop
//	instrMemory[13'h0002] = 14'b00_0000_0000_0000; //nop
//	instrMemory[13'h0003] = 14'b00_0000_0000_0000; //nop
//	instrMemory[13'h0004] = 14'b00_0000_0000_1001; //isr vector: retfie
//	instrMemory[13'h0005] = 14'b00_0000_0000_0000; //nop
//	instrMemory[13'h0006] = 14'b00_0000_0000_0000; //nop
//	instrMemory[13'h0007] = 14'b00_0000_0000_0000; //nop
//	instrMemory[13'h0008] = 14'b00_0000_0000_0000; //nop
//	instrMemory[13'h0009] = 14'b00_0000_0000_0000; //nop
//	instrMemory[13'h000a] = 14'b00_0000_0000_0000; //nop
//	instrMemory[13'h000b] = 14'b00_0000_0000_0000; //nop
//	instrMemory[13'h000c] = 14'b00_0000_0000_0000; //nop
//	instrMemory[13'h000d] = 14'b00_0000_0000_0000; //nop
//	instrMemory[13'h000e] = 14'b00_0000_0000_0000; //nop
//	instrMemory[13'h000f] = 14'b00_0000_0000_0000; //nop
//	
//	instrMemory[13'h0010] = 14'b01_0110_1000_0011; //bsf STATUS, RP0	//change to bank 1
//	instrMemory[13'h0011] = 14'b11_0000_0000_1111; //movlw 0x0F  
//	instrMemory[13'h0012] = 14'b00_0000_1000_0101; //movwf TRISA  //set half of PORTA as input and half as output
//	instrMemory[13'h0013] = 14'b01_0010_1000_0011; //bcf STATUS, RP0	//change to bank 0
//	
//	instrMemory[13'h0014] = 14'b00_1000_0000_0101; //movfw PORTA   //read PORTA into w
//	instrMemory[13'h0015] = 14'b00_1110_1000_0101; //swapf PORTA //swap nibbles of PORTA and store back into PORTA
//	instrMemory[13'h0016] = 14'b10_1000_0001_0100; //goto 0014		
//
//	instrMemory[13'h0017] = 14'b00_0000_0000_0000; //nop
//	instrMemory[13'h0018] = 14'b00_0000_0000_0000; //nop
//	instrMemory[13'h0019] = 14'b00_0000_0000_0000; //nop
//	instrMemory[13'h001a] = 14'b00_0000_0000_0000; //nop
//	instrMemory[13'h001b] = 14'b00_0000_0000_0000; //nop
//	instrMemory[13'h001c] = 14'b00_0000_0000_0000; //nop
//	instrMemory[13'h001d] = 14'b00_0000_0000_0000; //nop
//	instrMemory[13'h001e] = 14'b00_0000_0000_0000; //nop
//	instrMemory[13'h001f] = 14'b00_0000_0000_0000; //nop

end

always @(posedge clk)
	instrReg = instrMemory[addr];
		
always @(posedge clk)
	if(rst | flush)
		instr <= {INSTR_WIDTH{1'b0}};
	else if(rd_en)
		instr <= instrReg;
	
		
endmodule

