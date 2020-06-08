# TPM Specific lpc sniffer (low pin count) for ice40 stick

Turn the ice40 stick into a LPC sniffer, only logging TPM specific messages. This repository is a duplicate of [https://github.com/lynxis/lpc_sniffer/](https://github.com/lynxis/lpc_sniffer/), with modifications made to only log messages with start field `0101` and address between `24` and `27`.

This project was used to extract BitLocker VMK keys by sniffing the LPC bus when BitLocker was enabled in it's default configuration. More information is available [in this post](https://pulsesecurity.co.nz/articles/TPM-sniffing).

# features

- i/o read + writes
- memory read + writes
- sync errors

# How to use

1. modify EEPROM of the FTDI and enable OPTO mode on Channel B
1. program lpc_sniffer.bin into your ice40 by `iceprog lpc_sniffer.bin`
1. note: previous command can be replace by `make install`
1. connect the LPC bus
1. extract LPC data: python3 `./parse/read_serial.py /dev/ttyUSB1` | tee outlog
1. extract key from data: cut -f 2 -d\' outlog | grep '2...00$' | perl -pe 's/.{8}(..)..\n/$1/' | grep -Po "2c0000000100000003200000(..){32}"

# what connectors are used on the IceStick?

- J1 connector
```
	VCC 3.3|NC 1
	GND        2
	lpc_clock  3
	lpc_ad[0]  4
	lpc_ad[1]  5
	lpc_ad[2]  6
	lpc_ad[3]  7
	lpc_frame  8
	lpc_reset  9
```
- uart output over the ftdi

## LEDs

```
	For orientation: the usb port points south:
	green in the middle: overflow_led
```

overflow\_led when internal buffer is full. No more LPC frames are decoded

# Uart protocol

The LPC sniffer will write out frames onto the **second** uart of FTDI with 921600 baud.

## format

- 4 byte: address
- 1 byte: data
- 1 byte: 0-3bits: direction+type, 4-7: errorcode
- 2 byte: '\r\n'

## error codes

An error code is decoded in 4 bits
- 0001 - sync timeout.

# Internal documentation

A LPC frame will:

1. decoded by the LPC decoder
2. saved into the internal memory
3. padded by \r\n
4. written onto uart

## in memory layout

The internal memory is used as 48bit addressable memory.
48 bit is exact one lpc frame

- 4 byte: address
- 1 byte: data
- 1 byte: direction/type + error code

## internal buffer

The LPC sniffer is using an internal buffer. When the internal buffer
is full, new frames will be discarded. The green LED in the middle will turn on.
The internal buffer can save up to 2\*\*10 lpc frames (1024).

