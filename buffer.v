/* dual port memory */

module buffer #(parameter AW = 8, parameter DW = 8)
	(
		input clock,
		input write_clock_enable,
		input [DW-1:0] write_data,
		input [AW-1:0] write_addr,

		input read_clock_enable,
		output reg [DW-1:0] read_data,
		input [AW-1:0] read_addr);

	localparam NPOS = 2 ** AW;

	reg [DW-1: 0] ram [0: NPOS-1];

	always @(posedge clock)
		if (write_clock_enable)
			ram[write_addr] <= write_data;

	always @(posedge clock)
		if (read_clock_enable)
			read_data <= ram[read_addr];
endmodule
