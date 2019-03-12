`timescale 1 ns / 100 ps

module top_tb #(parameter CLOCK_FREQ = 12000000, parameter BAUD_RATE = 1200) ();

	reg [3:0] lpc_ad;
	reg lpc_clock;
	reg lpc_frame;
	reg lpc_reset;
	reg ext_clock;
	wire uart_tx_pin;
	wire lpc_clock_led;
	wire lpc_frame_led;
	wire lpc_reset_led;
	wire uart_tx_led;
	wire overflow_led;

	always
		#3 ext_clock = ~ext_clock;
	always
		#1 lpc_clock = ~lpc_clock;

	initial begin
		$dumpfile ("top_tb.vcd");
		$dumpvars (0, top_tb);
		#5000000 $finish;
	end

	initial begin
		ext_clock = 0;
		lpc_clock = 0;
		lpc_frame = 1;
		#10;
		lpc_reset = 0;
		#10;
		lpc_reset = 1;
		#10;

		/* writing LPC: io write 0x12 to 0x60 */
		@(posedge lpc_clock);
		/* start condition */
		lpc_frame = 0;
		lpc_ad = 'b0000;
		@(posedge lpc_clock);
		/* direction */
		lpc_frame = 1;
		lpc_ad = 'b0010;
		@(posedge lpc_clock);

		/* address 0x0060 */
		/* 00 = 1 byte */
		lpc_ad = 'h0;
		@(posedge lpc_clock);
		/* 00 = 1 byte */
		lpc_ad = 'h0;
		@(posedge lpc_clock);
		/* 00 = 1 byte */
		lpc_ad = 'h6;
		@(posedge lpc_clock);
		/* 00 = 1 byte */
		lpc_ad = 'h0;
		@(posedge lpc_clock);

		/* data */
		lpc_ad = 'h1;
		@(posedge lpc_clock);
		lpc_ad = 'hf;
		@(posedge lpc_clock);

		/* turn around time */
		@(posedge lpc_clock);
		@(posedge lpc_clock);

		/* sync */
		lpc_ad = 'h0;
		@(posedge lpc_clock);

		/* turn around time */
		@(posedge lpc_clock);
		@(posedge lpc_clock);

		#100;

		/* writing LPC: io read 0x12 to 0x60 */
		@(posedge lpc_clock);
		/* start condition */
		lpc_frame = 0;
		lpc_ad = 'b0000;
		@(posedge lpc_clock);
		/* direction */
		lpc_frame = 1;
		lpc_ad = 'b0000;
		@(posedge lpc_clock);

		/* address 0x0060 */
		/* 00 = 1 byte */
		lpc_ad = 'h0;
		@(posedge lpc_clock);
		/* 00 = 1 byte */
		lpc_ad = 'h0;
		@(posedge lpc_clock);
		/* 00 = 1 byte */
		lpc_ad = 'h6;
		@(posedge lpc_clock);
		/* 00 = 1 byte */
		lpc_ad = 'h0;
		@(posedge lpc_clock);

		/* turn around time */
		@(posedge lpc_clock);
		@(posedge lpc_clock);

		/* sync */
		lpc_ad = 'h0;
		@(posedge lpc_clock);

		/* data */
		lpc_ad = 'h1;
		@(posedge lpc_clock);
		lpc_ad = 'hf;
		@(posedge lpc_clock);

		/* turn around time */
		@(posedge lpc_clock);
		@(posedge lpc_clock);

		#100;

		/* writing LPC: mem read 0x12 to 0x60 */
		@(posedge lpc_clock);
		/* start condition */
		lpc_frame = 0;
		lpc_ad = 'b0000;
		@(posedge lpc_clock);
		/* cycle + direction */
		lpc_frame = 1;
		lpc_ad = 'b0100;
		@(posedge lpc_clock);

		/* address 0x12345678 */
		/* 00 = 1 byte */
		lpc_ad = 'h1;
		@(posedge lpc_clock);
		/* 00 = 1 byte */
		lpc_ad = 'h2;
		@(posedge lpc_clock);
		/* 00 = 1 byte */
		lpc_ad = 'h3;
		@(posedge lpc_clock);
		/* 00 = 1 byte */
		lpc_ad = 'h4;
		@(posedge lpc_clock);
		/* 00 = 1 byte */
		lpc_ad = 'h5;
		@(posedge lpc_clock);
		/* 00 = 1 byte */
		lpc_ad = 'h6;
		@(posedge lpc_clock);
		/* 00 = 1 byte */
		lpc_ad = 'h7;
		@(posedge lpc_clock);
		/* 00 = 1 byte */
		lpc_ad = 'h8;
		@(posedge lpc_clock);

		/* turn around time */
		@(posedge lpc_clock);
		@(posedge lpc_clock);

		/* sync */
		lpc_ad = 'h0;
		@(posedge lpc_clock);

		/* byte */
		lpc_ad = 'h1;
		@(posedge lpc_clock);
		lpc_ad = 'hf;
		@(posedge lpc_clock);

		/* turn around time */
		@(posedge lpc_clock);
		@(posedge lpc_clock);

		@(posedge lpc_clock);

		$finish;
	end


	top #(.CLOCK_FREQ(CLOCK_FREQ), .BAUD_RATE(BAUD_RATE))
		TOP (
			.lpc_ad(lpc_ad),
			.lpc_clock(lpc_clock),
			.lpc_frame(lpc_frame),
			.lpc_reset(lpc_reset),
			.ext_clock(ext_clock),
			.uart_tx_pin(uart_tx_pin),
			.lpc_clock_led(lpc_clock_led),
			.lpc_frame_led(lpc_frame_led),
			.lpc_reset_led(lpc_reset_led),
			.overflow_led(overflow_led));
endmodule
