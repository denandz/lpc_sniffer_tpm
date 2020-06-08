/* a lpc decoder
 * lpc signals:
	* lpc_ad: 4 data lines
	* lpc_frame: frame to start a new transaction. active low
	* lpc_reset: reset line. active low
 * output signals:
	* out_cyctype_dir: type and direction. same as in LPC Spec 1.1
	* out_addr: 32-bit address (16 would be enough)
	* out_data: data read or written (1byte)
	* out_clock_enable: on rising edge all data must read.
 */

module lpc(
	input wire [3:0] lpc_ad,
	input wire lpc_clock,
	input wire lpc_frame,
	input wire lpc_reset,
	input wire reset,
	output wire [3:0] out_cyctype_dir,
	output wire [31:0] out_addr,
	output wire [7:0] out_data,
	output reg out_sync_timeout,
	output reg out_clock_enable);

	/* state machine */	
	localparam[4:0] STATE_IDLE = 4'd0;
	localparam[4:0] STATE_START = 4'd1;
	localparam[4:0] STATE_CYCLE_DIR = 4'd2;
	localparam[4:0] STATE_ADDRESS_CLK1 = 4'd3;
	localparam[4:0] STATE_ADDRESS_CLK2 = 4'd4;
	localparam[4:0] STATE_ADDRESS_CLK3 = 4'd5;
	localparam[4:0] STATE_ADDRESS_CLK4 = 4'd6;
	localparam[4:0] STATE_TAR_CLK1 = 4'd7;
	localparam[4:0] STATE_TAR_CLK2 = 4'd8;
	localparam[4:0] STATE_SYNC = 4'd9;
	localparam[4:0] STATE_READ_DATA_CLK1 = 4'd10;
	localparam[4:0] STATE_READ_DATA_CLK2 = 4'd11;
	localparam[4:0] STATE_ABORT = 4'd12;
	localparam[4:0] STATE_TAREND_CLK1 = 4'd13;
	localparam[4:0] STATE_TAREND_CLK2 = 4'd14;
	reg [3:0] state = STATE_IDLE;

	// registers
	reg [3:0] cyctype_dir;				// mode & direction, same as in LPC Spec 1.1
	reg [31:0] addr = 32'd0;			// 32 bit address
	reg [7:0] data;				// 8 bit data

	// combinatorial logic
	assign out_cyctype_dir = cyctype_dir;
	assign out_data = data;
	assign out_addr = addr;
	
	// synchronous logic
	// Clock goes high, or RESET goes low (active low reset)
	always @(negedge lpc_clock  or negedge lpc_reset)
	begin
		if (~lpc_reset)
		begin
			state <= STATE_IDLE;
		end else
		begin
			// Start condition is having LPC_FRAME low and LAD = 0101 for TPM reads
			if (~lpc_frame && lpc_ad == 4'b0101)
			begin
				out_clock_enable <= 1'b0;
				out_sync_timeout <= 1'b0;
				state <= STATE_CYCLE_DIR;
			end
			
			// If LPC_FRAME is high, then we have data
			if (lpc_frame)			
			begin
				// State machine for frame
				case (state)
					STATE_CYCLE_DIR:
					begin
						// cyctype_dir[3:0] <= lpc_ad[3:0];
						cyctype_dir <= lpc_ad;
						
						if (cyctype_dir[3:2] == 2'b00) // I/O
						begin
							if (cyctype_dir[1] == 1'd0) // Read
							begin
								state <= STATE_ADDRESS_CLK1;
							end else // Write
							begin
								state <= STATE_IDLE;
							end
						end else 
						begin
							state <= STATE_IDLE; // unsupported DMA or reserved
						end
					   
					end

					STATE_ADDRESS_CLK1:
					begin
						addr[15:12] <= lpc_ad;
						state <= STATE_ADDRESS_CLK2;
					end

					STATE_ADDRESS_CLK2:
					begin
						addr[11:8] <= lpc_ad;
						state <= STATE_ADDRESS_CLK3;
					end

					STATE_ADDRESS_CLK3:
					begin
						addr[7:4] <= lpc_ad;
						state <= STATE_ADDRESS_CLK4;
					end

					STATE_ADDRESS_CLK4:
					begin
						addr[3:0] <= lpc_ad;
						state <= STATE_TAR_CLK1;
					end



					STATE_TAR_CLK1:
					begin
						// On first clock LAD are 1111, on second clock it goes Z
						if (lpc_ad == 4'b1111)
						begin
							// Most TPM are using address 24 only, but some (ST, infineon) use 24 to 27 for FIFO
							if (addr >= 32'h24 && addr <= 32'h27)
							begin 
								state <= STATE_TAR_CLK2;
							end else 
							begin
								state <= STATE_IDLE;
							end
						   
						end
					end
							
					STATE_TAR_CLK2:
					begin
						state <= STATE_SYNC;
					end
					
					

					STATE_SYNC:
					begin
						// Ready when LAD is 0000
						if (lpc_ad == 4'b0000)
						begin
						   state <= STATE_READ_DATA_CLK1;
						end
					end

					STATE_READ_DATA_CLK1:
					begin
						data[3:0] <= lpc_ad;
						state <= STATE_READ_DATA_CLK2;
					end
					
					STATE_READ_DATA_CLK2:
					begin
						data[7:4] <= lpc_ad;
						state <= STATE_TAREND_CLK1;
					end



					STATE_TAREND_CLK1:
					begin
						state <= STATE_TAREND_CLK2;
					end
					STATE_TAREND_CLK2:
					begin
						// No need to check for addr, it was already filtered on first TAR
						out_clock_enable <= 1;
						state <= STATE_IDLE;
					end
					
				endcase
			end
		end
	end
endmodule

