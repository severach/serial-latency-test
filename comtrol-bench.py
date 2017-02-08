#!/usr/local/bin/python.exe

# Benchmark Prepared and Executed By:
# Grant Edwards, Sr. Principal Engineer, Comtrol Corporation
# David Boldt , Sr. Technical Consultant, Comtrol Corporation
# (C) 2003 by Comtrol Corporation, All Rights Reserved.

from win32file import *
from win32event import *
import win32con
import getopt, time, sys, operator, math, random, socket

def mean(v):
    return reduce(operator.add,v)/len(v)

def stddev(v,m):
    devsq = [(x-m)*(x-m) for x in v]
    return math.sqrt(reduce(operator.add,devsq)/(len(devsq)-1))

def toHex(data):
    return " ".join(["%02x" % ord(c) for c in data])

def openPort(s):
    if not s.startswith('\\'):
        s = "\\\\.\\" + s
    handle = CreateFile(s, win32con.GENERIC_READ | win32con.GENERIC_WRITE,
                        0, None, # exclusive access, no security
                        win32con.OPEN_EXISTING,
                        win32con.FILE_ATTRIBUTE_NORMAL, None)
    SetCommMask(handle, EV_RXCHAR)
    SetupComm(handle, 4096, 4096)
    PurgeComm(handle, PURGE_TXABORT|PURGE_RXABORT|PURGE_TXCLEAR|PURGE_RXCLEAR)
    SetCommTimeouts(handle, (ictimeout, 0, timeout, 0, timeout))
    dcb = GetCommState(handle)
    dcb.BaudRate = eval("CBR_%d" % baud)
    dcb.ByteSize = 8
    dcb.fOutX = 0
    dcb.fInX = 0
    dcb.Parity = NOPARITY
    dcb.StopBits = ONESTOPBIT
    SetCommState(handle, dcb)
    print "Connected to %s at %s baud" % (s, dcb.BaudRate)
    return handle

testData = "".join([chr((i&0xff)|0x40) for i in range(2048)])

opts,ports = getopt.getopt(sys.argv[1:],"qc:d:b:s:i:t:",
                           ("count=","delay=","baud=","size=",
                            "interchar-timeout=","timeout=","quiet"))
baud = 9600
count = 100
delay = 100
blocksize = 1
ictimeout = 2
timeout = 2000
quiet = 0

for opt,val in opts:
    if opt in ('-c', '--count'):
        count = int(val)
    elif opt in ('-d', '--delay'):
        delay = int(val)
    elif opt in ('-s', '--size'):
        blocksize = int(val)
    elif opt in ('-b', '--baud'):
        baud = int(val)
    elif opt in ('-i','--interchar-timeout'):
        ictimeout = int(val)
    elif opt in ('-t','--timeout'):
        timeout = int(val)
    elif opt in ('-q','--quiet'):
        quiet = 1
    else:
        raise "Unknown option "+opt

if ictimeout <= 0:
    ictimeout = 0xFFFFFFFF

if len(ports) < 1 or len(ports) > 2:
    raise "need one or two port IDs"

txhandle = openPort(ports[0])
if len(ports) == 2 and ports[0] != ports[1]:
    rxhandle = openPort(ports[1])
else:
    rxhandle = txhandle

loops = 0
deltas = []

delay = delay / 1000.0   # convert delay from ms to seconds

while loops < count:
    txdata = testData[(loops & 0xff):][:blocksize]
    txTime = time.clock()
    rxdata = ''
    rc,txcount = WriteFile(txhandle,txdata)
    if rc or txcount != len(txdata):
        raise "WriteFile error %d,%d" % (rc,txcount)
    while 1:
        rc,data = ReadFile(rxhandle,blocksize)
        if rc:
             raise "ReadFile error %d" % rc
        rxdata += data
        if len(txdata) == len(rxdata):
             break
    rxTime = time.clock()
    if rxdata != txdata:
        sys.stdout.write("Tx: %s\n" % toHex(txdata))
        sys.stdout.write("Rx: %s\n" % toHex(rxdata))
        sys.stdout.flush()
        raise "data error"
    delta = (rxTime-txTime)*1000.0 # convert elapsed time to ms
    deltas.append(delta)
    sys.stdout.write("%d %5.1f\n" % (loops,delta))
    time.sleep(delay)
    loops += 1

deltaMean = mean(deltas)
deltaSD = stddev(deltas,deltaMean)

sys.stdout.write("min/mean/max SD = %0.2f %0.2f %0.2f %0.2f\n" % \
                 (min(deltas),deltaMean,max(deltas),deltaSD))
