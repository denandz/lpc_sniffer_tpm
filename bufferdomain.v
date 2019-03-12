module bufferdomain #(parameter AW = 8)
	(
		input [AW-1:0] input_data,
		output reg [AW-1:0] output_data,
		input reset, // active low
		output reg output_enable,
		input clock,
		input input_enable);


	reg [1:0] counter;

	always @(posedge input_enable) begin
		if (input_enable) begin
			output_data <= input_data;
		end
	end

	always @(posedge input_enable or negedge clock) begin
		if (input_enable) begin
			counter <= 2;
		end else begin
			if (~reset) begin
				counter <= 0;
			end else begin
				if (counter != 0)
					counter <= counter - 1;
			end
		end
	end
	always @(*) begin
		if (counter == 1)
			output_enable = 1;
		else
			output_enable = 0;
	end

endmodule
