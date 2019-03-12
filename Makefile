
NAME=top
DEPS=buffer.v bufferdomain.v lpc.v mem2serial.v ringbuffer.v power_on_reset.v trigger_led.v pll.v ftdi.v

$(NAME).bin: $(NAME).pcf $(NAME).v $(DEPS)
	yosys -p "synth_ice40 -blif $(NAME).blif" $(NAME).v $(DEPS)
	arachne-pnr -d 1k -p $(NAME).pcf $(NAME).blif -o $(NAME).txt
	icepack $(NAME).txt $(NAME).bin
	cp $(NAME).bin lpc_sniffer.bin

buffer.vvp: buffer_tb.v buffer.v
	iverilog -o buffer_tb.vvp buffer_tb.v buffer.v

mem2serial.vvp: mem2serial_tb.v mem2serial.v
	iverilog -o mem2serial_tb.vvp mem2serial_tb.v mem2serial.v

ringbuffer.vvp: ringbuffer_tb.v ringbuffer.v buffer.v
	iverilog -o ringbuffer_tb.vvp ringbuffer_tb.v ringbuffer.v buffer.v

uart_tx_tb.vvp: uart_tx_tb.v uart_tx.v
	iverilog -o uart_tx_tb.vvp uart_tx_tb.v uart_tx.v

top_tb.vpp: top_tb.v top.v buffer.v bufferdomain.v lpc.v mem2serial.v ringbuffer.v uart_tx.v power_on_reset.v trigger_led.v pll.v ./test/sb_pll40_core_sim.v
	iverilog -o top_tb.vpp top_tb.v top.v buffer.v bufferdomain.v lpc.v mem2serial.v ringbuffer.v uart_tx.v power_on_reset.v trigger_led.v pll.v ./test/sb_pll40_core_sim.v

test/helloonechar_tb.vvp: uart_tx_tb.v uart_tx.v test/helloonechar_tb.v power_on_reset.v
	iverilog -o test/helloonechar_tb.vvp test/helloonechar_tb.v uart_tx.v power_on_reset.v

test/helloworld_tb.vvp: test/helloworld_tb.v test/helloworld.v mem2serial.v ringbuffer.v buffer.v uart_tx.v power_on_reset.v test/helloworldwriter.v
	iverilog -o test/helloworld_tb.vvp test/helloworld_tb.v test/helloworld.v mem2serial.v ringbuffer.v buffer.v uart_tx.v power_on_reset.v test/helloworldwriter.v

test/helloworld.bin: test/helloworld.v mem2serial.v ringbuffer.v buffer.v uart_tx.v power_on_reset.v test/helloworldwriter.v test/helloworld.pcf
	yosys -p "synth_ice40 -blif test/helloworld.blif" test/helloworld.v mem2serial.v ringbuffer.v buffer.v uart_tx.v power_on_reset.v test/helloworldwriter.v
	arachne-pnr -d 1k -p test/helloworld.pcf test/helloworld.blif -o test/helloworld.txt
	icepack test/helloworld.txt test/helloworld.bin

test/helloonechar.bin: test/helloonechar.v uart_tx.v power_on_reset.v test/helloonechar.pcf
	yosys -p "synth_ice40 -blif helloonechar.blif" helloonechar.v uart_tx.v power_on_reset.v
	arachne-pnr -d 1k -p test/helloonechar.pcf test/helloonechar.blif -o test/helloonechar.txt
	icepack test/helloonechar.txt test/helloonechar.bin

clean:
	rm -f top.blif top.txt top.ex top.bin

test: buffer.vvp mem2serial.vvp ringbuffer.vvp uart_tx_tb.vvp top_tb.vpp test/helloonechar_tb.vvp test/helloworld_tb.vvp

install: top.bin
	iceprog top.bin

.PHONY: install
