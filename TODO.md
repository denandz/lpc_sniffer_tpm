# TODO

## LPC modes
* implement memory read / writes
* abort on LPCFRAME# when driving not in idle mode

## Testbench for every module

every module needs a testbench

##  Implement a raw LPC capture without decodes

To debug the lpc sniffer I need the raw frames.
Create a second lpc sniffer modules which only captures
all frame bit-bit. Starting x bytes after lpc\_frame driven low (start or abort conidtion)

### lpc

* check if lpc\_frame can abort a cycle
* check lpc\_reset
* check i/o read / write
* check memory read / write

### ringbuffer

* implement in the test bench: 
  * check if write increases the pointer
  * check if read increases the pointer
  * check if overflow happens
  * check if emptyness happens after overflow + multiple reads
  * check write, read, write, write, write,read, read, write, read, read

### mem2serial

* improve test bench

### serial

* improve test bench

### top

* check if given lpc frame ends up on the uart pin
