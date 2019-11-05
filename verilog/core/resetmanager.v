module resetmanager(
	input wire clk,
	input wire rst_ext,
	input wire wdt_timeout,
	
	output reg rst
);

initial rst = 1'd0;

//todo: this is just a placeholder
always@(*) begin
	rst <= rst_ext;
end

endmodule
