
`timescale 1 ns / 100 ps

module buffer_tb ();
	reg write_clock;
	reg [7:0] write_data;
	reg [7:0] write_addr;

	reg read_clock;
	wire [7:0] read_data;
	reg [7:0] read_addr;

	buffer #(.AW(8), .DW(8))
		MEM (
			.clock(clock),
			.write_clock_enable(read_clock_enable),
			.write_data(write_data),
			.write_addr(write_addr),
			.read_clock_enable(read_clock_enable),
			.read_data(read_data),
			.read_addr(read_addr));

	initial begin
		$dumpfile ("buffer_tb.vcd");
		$dumpvars (1, buffer_tb);
		#1;
		write_addr = 0;
		write_data = 'hf1;
		write_clock = 1;
		#1;
		write_clock = 0;
		#1;
		read_addr = 0;
		read_clock = 1;
		#1;
		read_clock = 0;
		if (read_data != 'hf1) begin
			$display("wrong data read at addr %x. expect data: %x, but read %x", read_addr, 'hf1, read_data);
			$stop;
		end
		#1;

		// overwrite old data and check if write_clock is required to change data
		write_data = 'hee;
		read_clock = 1;
		#1;
		read_clock = 0;
		#1;
		if (read_data != 'hf1) begin
			$display("read data changed even write_clock wasn\'t triggered. read addr %x. expect data: %x, but read %x", read_addr, 'hf1, read_data);
			$stop;
		end

		#1;
		write_clock = 1;
		// overwrite old data and check if read gets overwritten
		if (read_data != 'hf1) begin
			$display("read data changed even read_clock wasn\'t triggered. read addr %x. expect data: %x, but read %x", read_addr, 'hf1, read_data);
			$stop;
		end

		#2;
		read_clock = 1;
		#2
		read_clock = 0;
		if (read_data != 'hee) begin
			$display("read wrong data. read addr %x. expect data: %x, but read %x", read_addr, 'hee, read_data);
			$stop;
		end

		$finish;
	end
endmodule
