module helloworldwriter(
	input clock,
	input reset,
	input overflow,
	output out_clock_enable,
	output reg [47:0] out_data);

	reg [1:0] counter;

	assign out_clock_enable = 1;

	always @(negedge clock or negedge reset) begin
		if (~reset)
			counter <= 0;
		else begin
			if (~overflow) begin
				if (counter == 0) begin
					out_data <= 48'h68656c6c6f20; /* 'hello ' */
				end
				else if (counter == 1) begin
					out_data <= 48'h776f726c6421; /* 'world!' */
				end
				else if (counter == 2) begin
					out_data <= 48'h666f6f626172; /* 'foobar' */
				end
				else if (counter == 3) begin
					out_data <= 48'h796970796970; /* 'yipyip' */
				end
				counter <= counter + 1;
			end
		end
	end
endmodule
