module trigger_led
	(
		input trigger,
		input clock,
		input reset,
		output reg led
	);

	reg [23:0] counter;

	always @(posedge trigger or negedge clock) begin
		if (trigger) begin
			led <= 1;
			counter <= 1_000_000;
		end else begin
			if (~reset) begin
				counter <= 0;
				led <= 0;
			end else begin
				if (counter == 0) begin
					led <= 0;
				end
				counter <= counter - 1;
			end
		end
	end
endmodule
