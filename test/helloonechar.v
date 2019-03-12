module helloonechar #(parameter CLOCK_FREQ = 12000000, parameter BAUD_RATE = 9600)
(
	input ext_clock,
	output uart_tx_pin,
	output uart_tx_led,
	output counter_led,
	output uart_clock_led);

	wire reset;

	/* uart tx */
	wire uart_ready;
	wire [7:0] uart_data;
	wire uart_clock_enable;
	wire uart_clock;
	reg [32:0] count;

	power_on_reset POR(
		.clock(ext_clock),
		.reset(reset));

	always @(*) begin
		uart_data = 8'h1f;
	end

	always @(negedge ext_clock or negedge reset) begin
		if (~reset) begin
			uart_clock_enable <= 1;
			count <= 12000000;
		end else begin
			if (~uart_ready)
				uart_clock_enable <= 0;
			else  begin
				if (count == 0) begin
					counter_led <= ~counter_led;
					count <= 12000000;
					uart_clock_enable <= 1;
				end
				else begin
					count <= count - 1;
				end
			end
		end
	end

	uart_tx #(.CLOCK_FREQ(CLOCK_FREQ), .BAUD_RATE(BAUD_RATE))
		SERIAL (.read_data(uart_data),
			.read_clock_enable(uart_clock_enable),
			.reset(reset),
			.ready(uart_ready),
			.tx(uart_tx_pin),
			.clock(ext_clock),
			.uart_clock(uart_clock));

	assign uart_tx_led = uart_tx_pin;
	assign uart_clock_led = uart_clock;
endmodule
