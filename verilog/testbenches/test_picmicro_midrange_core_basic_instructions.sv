`timescale 1ns/1ns

module test_picmicro_midrange_core_basic_instructions;

reg clk, clk_wdt, rst_ext;

initial begin: CLOCK_GENERATOR
	clk = 0;
	clk_wdt = 0;
	forever begin 
		#5 clk = ~clk; //every 5ns invert the clock
	end
end

initial begin: EXT_RST_GENERATOR
	rst_ext = 1;
	#10 rst_ext = 0; //after 10ns clear the reset
end

picmicro_midrange_core core(
	.clk(clk),
	.clk_wdt(clk_wdt),
	.rst_ext(rst_ext),
	
	.extern_peripherals_data_out(8'd0)
);

//set the program to test
initial begin
	$readmemb("test.prog", core.progmem.instrMemory);
	#10 //end of reset
	if(core.pc_out != 0)
		$display("bad");
	else
		$display("good");
	
end
endmodule
