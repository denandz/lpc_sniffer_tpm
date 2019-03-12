`timescale 1 ns / 100 ps

module helloonechar_tb #(parameter CLOCK_FREQ = 4800, parameter BAUD_RATE = 1200) ();
	reg ext_clock;
	wire uart_tx_pin;
	wire uart_tx_led;
	wire uart_clock_led;

	wire reset;

	/* uart tx */
	wire uart_ready;
	reg [7:0] uart_data;
	reg uart_clock_enable;
	reg [7:0] count;
	wire uart_clock;

	power_on_reset POR(
		.clock(ext_clock),
		.reset(reset));

	always
		#2 ext_clock = ~ext_clock;

	initial begin
		#500000 $finish;
	end

	initial begin
		$dumpfile ("helloonechar_tb.vcd");
		$dumpvars (0, helloonechar_tb);
		ext_clock = 0;
	end

	initial begin
		uart_data = 8'h60;
	end

	always @(negedge uart_ready or negedge reset) begin
		if (~reset) begin
			uart_clock_enable <= 1;
			count <= 16;
		end else begin
			if (count == 0)
				uart_clock_enable <= 0;
			else
				count <= count - 1;
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
