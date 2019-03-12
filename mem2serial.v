module mem2serial #(parameter AW = 8)
	(
		output reg read_clock_enable,
		input [47:0] read_data,
		input read_empty, // high is input is empty
		input reset, // active low
		input clock,

		input uart_ready,
		output reg [7:0] uart_data,
		output reg uart_clock_enable);

	parameter idle = 0, write_data = 1, wait_write_done = 2,
		write_trailer = 3, wait_write_trailer_done = 4;
	reg [2:0] state;
	reg [7:0] write_pos;
	reg [47:0] data;

	always @(negedge reset or negedge clock) begin
		if (~reset) begin
			state <= idle;
			uart_clock_enable <= 0;
			read_clock_enable <= 0;
			write_pos <= 00;
		end
		else
			case (state)
				idle: begin
					if (~read_empty)
						if (read_clock_enable) begin
							data <= read_data;
							state <= write_data;
							read_clock_enable <= 0;
							write_pos <= 40;
						end else
							read_clock_enable <= 1;
					else
						read_clock_enable <= 0;
				end
				write_data: begin
						if (uart_ready) begin
							uart_data[7] <= data[write_pos + 7];
							uart_data[6] <= data[write_pos + 6];
							uart_data[5] <= data[write_pos + 5];
							uart_data[4] <= data[write_pos + 4];
							uart_data[3] <= data[write_pos + 3];
							uart_data[2] <= data[write_pos + 2];
							uart_data[1] <= data[write_pos + 1];
							uart_data[0] <= data[write_pos + 0];
							uart_clock_enable <= 1;
							write_pos <= write_pos - 8;
							state <= wait_write_done;
						end
				end
				wait_write_done: begin
					if (~uart_ready) begin
						uart_clock_enable <= 0;
						if (write_pos > 40) begin /* overflow. finished writing */
							write_pos <= 0;
							state <= write_trailer;
						end else
							state <= write_data;
					end
				end
				write_trailer: begin
					if (uart_ready) begin
						if (write_pos == 0) begin
							uart_clock_enable <= 1;
							uart_data <= 'h0a;
							state <= wait_write_trailer_done;
						end
						else if (write_pos >= 1) begin
							state <= idle;
						end

						write_pos <= write_pos + 1;
					end
				end
				wait_write_trailer_done: begin
					if (~uart_ready) begin
						uart_clock_enable <= 0;
						state <= write_trailer;
					end
				end
			endcase
	end
endmodule
