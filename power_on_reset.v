module power_on_reset(
	input pll_locked,
	input clock,
	output reg reset);

reg [31:0] counter = 32'h2;

always @(*) begin
	if (counter == 0)
		reset = 1;
	else
		reset = 0;
end

always @(negedge clock) begin
	if (counter != 0 && pll_locked)
		counter <= counter - 1;
end

endmodule
