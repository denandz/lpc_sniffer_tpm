#!/usr/bin/env python3

from binascii import hexlify
import sys

def parse_line(line):
    if not line:
        return None
    if len(line) != 6:
        return None
    lpctype = ''
    direction = ''
    address = ''
    data = ''
    if (line[5] & 0xc) == 0:
        lpctype = 'io'
    elif (line[5] & 0xc) == 1:
        lpctype = 'mem'
    if (line[5] & 0x2) == 0:
        direction = 'read'
    else:
        direction = 'write'
    data = hexlify(line[4:5]).decode()
    address = hexlify(line[0:4]).decode()
    return (lpctype, direction, address, data)

def parse_file(rawfile):
    # open file
    rawdata = open(rawfile, 'rb')

    # get file length
    rawdata.seek(0, 2)
    length = rawdata.seek(0, 2)
    rawdata.seek(0, 0)

    rawdata = rawdata.read(length)
    lines = rawdata.splitlines()

    parsed = []

    for line in lines:
        lpc = parse_line(line)
        if not lpc:
            continue
        lpctype, direction, address, data = lpc
        parsed.append('%3s: %5s %8s: %4s\n' % (lpctype, direction, address, data))
    return parsed

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("parse parsefile")
        sys.exit(0)

    PARSED = parse_file(sys.argv[1])
    print("".join(PARSED))
