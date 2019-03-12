#!/usr/bin/env python3

from binascii import hexlify
import sys
import serial
import parse

if len(sys.argv) != 2:
    print("read_serial /dev/ttyUSB4")
    sys.exit(1)

# ser = serial.Serial(sys.argv[1], 115200)
# ser = serial.Serial(sys.argv[1], 2_000_000)
# ser = serial.Serial(sys.argv[1], 921600)
ser = serial.Serial(sys.argv[1], 2000000)
while True:
    line = ser.readline()
    line = line.strip(b'\r\n')
    print(hexlify(line))
#    lpc = parse.parse_line(line)
#    if not lpc:
#        continue
#    lpctype, direction, address, data = lpc
#    print('%3s: %5s %8s: %4s' % (lpctype, direction, address, data))
