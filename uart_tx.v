
module uart_tx #(parameter CLOCK_FREQ = 12_000_000, BAUD_RATE = 115_200)
	(
	input clock,
	input [7:0] read_data,
	input read_clock_enable,
	input reset, /* active low */
	output reg ready, /* ready to read new data */
	output reg tx,
	output reg uart_clock);

	reg [9:0] data;

	localparam CLOCKS_PER_BIT = CLOCK_FREQ / BAUD_RATE / 2;
	reg [24:0] divider;

	reg new_data;
	reg state;
	reg [3:0] bit_pos; /* which is the next bit we transmit */

	localparam IDLE = 1'h0, DATA = 1'h1;

	always @(negedge reset or posedge clock) begin
		if (~reset) begin
			uart_clock <= 0;
			divider <= 0;
		end
		else if (divider >= CLOCKS_PER_BIT) begin
			divider <= 0;
			uart_clock <= ~uart_clock;
		end
		else
			divider <= divider + 1;
	end

	always @(negedge clock or negedge reset) begin
		if (~reset) begin
			ready <= 0;
			new_data <= 0;
		end
		else begin
			if (state == IDLE) begin
				if (~new_data)
					if (~ready)
						ready <= 1;
					else if (read_clock_enable) begin
						/* stop bit */
						data[0] <= 0;
						data[8:1] <= read_data;
						/* start bit */
						data[9] <= 1;
						new_data <= 1;
						ready <= 0;
					end
			end
			else
				new_data <= 0;
		end
	end

	always @(negedge uart_clock or negedge reset) begin
		if (~reset) begin
			state <= IDLE;
		end
		else begin
			case (state)
				IDLE: begin
					tx <= 1;
					if (new_data) begin
						state <= DATA;
						bit_pos <= 0;
					end
				end
				DATA: begin
					tx <= data[bit_pos];
					if (bit_pos == 9)
						state <= IDLE;
					else
						bit_pos <= bit_pos + 1;
				end
			endcase
		end
	end
endmodule

