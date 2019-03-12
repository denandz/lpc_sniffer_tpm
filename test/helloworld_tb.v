`timescale 1 ns / 100 ps

module helloworld_tb #(parameter CLOCK_FREQ = 4800, parameter BAUD_RATE = 1200) ();

	reg ext_clock;
	wire uart_tx_pin;
	wire uart_tx_led;
	wire uart_clock_led;

	always
		#1 ext_clock = ~ext_clock;

	initial begin
		ext_clock = 0;
		$dumpfile ("helloworld_tb.vcd");
		$dumpvars (0, helloworld_tb);
		#5000000 $finish;
	end

	helloworld #(.CLOCK_FREQ(CLOCK_FREQ), .BAUD_RATE(BAUD_RATE))
		HELLOWORLD (.ext_clock(ext_clock),
			.uart_tx_pin(uart_tx_pin),
			.uart_tx_led(uart_tx_led),
			.uart_clock_led(uart_clock_led));
endmodule
