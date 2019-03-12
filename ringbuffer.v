module ringbuffer #(parameter AW = 8, DW = 48)
	(
		input reset,
		input clock,
		input read_clock_enable,
		input write_clock_enable,
		output [DW-1:0] read_data,
		input [DW-1:0] write_data,
		output reg empty,
		output reg overflow);

	reg [AW-1:0] next_write_addr;

	reg [AW-1:0] read_addr;
	reg [AW-1:0] write_addr;

	wire mem_read_clock_enable;
	wire mem_write_clock_enable;

	assign empty = read_addr == write_addr;
	assign overflow = next_write_addr == read_addr;

	always @(negedge reset or negedge clock) begin
		if (~reset) begin
			write_addr <= 0;
			next_write_addr <= 1;
		end
		else
			if (write_clock_enable)
				if (~overflow) begin
					write_addr <= write_addr + 1;
					next_write_addr <= next_write_addr + 1;
				end
	end

	always @(negedge reset or negedge clock) begin
		if (~reset) begin
			read_addr <= 0;
		end
		else begin
			if (read_clock_enable)
				if (~empty)
					read_addr <= read_addr + 1;
		end
	end

	assign mem_read_clock_enable = ~empty & read_clock_enable;
	assign mem_write_clock_enable = ~overflow & write_clock_enable;

	buffer #(.AW(AW), .DW(DW))
		MEM (
			.clock(clock),
			.write_clock_enable(mem_write_clock_enable),
			.write_data(write_data),
			.write_addr(write_addr),
			.read_clock_enable(mem_read_clock_enable),
			.read_data(read_data),
			.read_addr(read_addr));
endmodule
