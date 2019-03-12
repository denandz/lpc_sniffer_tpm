module helloworld #(parameter CLOCK_FREQ = 12000000, parameter BAUD_RATE = 115200)
(
	input ext_clock,
	output uart_tx_pin,
	output uart_tx_led,
	output uart_clock_led);

	wire reset;

	wire [47:0] write_data;

	/* ring buffer */
	wire read_clock_enable;
	wire write_clock_enable;
	wire empty;
	wire overflow;

	/* mem2serial */
	wire [47:0] read_data;

	/* uart tx */
	wire uart_ready;
	wire [7:0] uart_data;
	wire uart_clock_enable;
	wire uart_clock;
	wire [47:0] read_data_static;
	wire empty_static;

	power_on_reset POR(
		.clock(ext_clock),
		.reset(reset));

	/* write hello world */
	helloworldwriter HELLOWORLDWRITER(
		.clock(ext_clock),
		.reset(reset),
		.overflow(overflow),
		.out_data(write_data),
		.out_clock_enable(write_clock_enable));

	ringbuffer #(.AW(10), .DW(48))
		RINGBUFFER (
			.reset(reset),
			.clock(ext_clock),
			.write_clock_enable(write_clock_enable),
			.read_clock_enable(read_clock_enable),
			.read_data(read_data),
			.write_data(write_data),
			.empty(empty),
			.overflow(overflow));

	mem2serial MEM_SERIAL(
		.reset(reset),
		.clock(ext_clock),
		.read_empty(empty),
		.read_clock_enable(read_clock_enable),
		.read_data(read_data),
		.uart_clock_enable(uart_clock_enable),
		.uart_ready(uart_ready),
		.uart_data(uart_data));

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
