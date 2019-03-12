
`timescale 1 ns / 100 ps

module uart_tx_tb ();
	reg clock;
	reg [7:0] read_data;
	reg read_clock_enable;
	reg reset; /* active low */
	wire ready; /* ready to read new data */
	wire tx;
	wire uart_clock;

	uart_tx #(.CLOCK_FREQ(2_400), .BAUD_RATE(1_200))
		UART (
			.reset(reset),
			.clock(clock),
			.read_data(read_data),
			.read_clock_enable(read_clock_enable),
			.tx(tx),
			.ready(ready),
			.uart_clock(uart_clock));

	always
		#2 clock = ~clock;

	initial begin
		#5000 $finish;
	end

	initial begin
		$dumpfile ("uart_tx_tb.vcd");
		$dumpvars (0, uart_tx_tb);
		clock = 0;
		reset = 0;
		read_data = 8'hb7;
		read_clock_enable = 1;
		#10
		if (ready == 'b1) begin
			$display("ready in reset is high. Expected: low");
			$stop;
		end
		#2
		read_clock_enable = 0;
		#20 reset = 1;
		#2;
		#2;
		#2;
		reset = 1;
		#500;
		if (ready == 'b0) begin
			$display("ready after reset is low. Expected: high");
			$stop;
		end
		#2;
		read_clock_enable = 1;
		@(negedge ready);
		read_clock_enable = 0;
		#2000;

		$finish;
	end
endmodule
