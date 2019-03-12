`timescale 1 ns / 100 ps

module mem2serial_tb ();
	reg reset;
	reg clock;
	reg empty;
	wire read_clock_enable;
	reg [47:0] read_data;
	wire uart_clock_enable;
	reg uart_ready;
	wire [7:0] uart_data;
	reg read_clock;

	mem2serial MEM_SERIAL(
		.reset(reset),
		.clock(clock),
		.read_empty(empty),
		.read_clock_enable(read_clock_enable),
		.read_data(read_data),
		.uart_clock_enable(uart_clock_enable),
		.uart_ready(uart_ready),
		.uart_data(uart_data));

	initial begin
		$dumpfile ("mem2serial_tb.vcd");
		$dumpvars (1, mem2serial_tb);
		#1;
		read_data = 48'h0;
		empty = 1;
		clock = 0;
		reset = 0;
		uart_ready = 0;
		#1;
		clock = 1;
		#1;
		clock = 0;
		#1;
		reset = 1;
		#1;
		clock = 1;
		#1;
		// test if data read when ~uart_ready but it should not read more than
		clock = 0;
		empty = 0;
		read_data = 48'h123456789a;
		uart_ready = 0;
		#1;
		clock = 1;
		#1;
		clock = 0;
		read_data = 48'h0;
		// it should disable read_clock_enable
		if (read_clock_enable == 'b1) begin
			$display("read_clock_enable still high. Expected: low");
			$stop;
		end

		// ensure no data will read when uart_ready + empty
		// check if data successful read when uart_ready
		// ensure nodata will read when ~uart_ready + ~empty
		$finish;
	end
endmodule
