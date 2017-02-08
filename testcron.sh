#!/bin/bash

cd "$(dirname "$0")" # cron compatible
#./serial-latency-test.pl -c 10 --errors -o 'testcron.txt' -b 0 -qqqrr --title $'Digi PortServer II 16 RealPort' '/dev/ttyaf00' '/dev/ttyUSB0'
#./serial-latency-test.pl -c 10 --errors -o 'testcron.txt' -b 0 -qqqrr --title $'Digi PortServer TS 2 RealPort' '/dev/ttyaf00' '/dev/ttyUSB0'
./serial-latency-test.pl -c 10 --errors -o 'testcron.txt' -b 0 -qqqrr --title $'Digi PortServer TS 1 RealPort' '/dev/ttyaf00' '/dev/ttyUSB0'
#./serial-latency-test.pl -c 10 --errors -o 'testcron.txt' -b 0 -qqqrr --title $'Perle SDS-2 TruePort' '/dev/tx0000' '/dev/ttyS0'
#./serial-latency-test.pl -c 10 --errors -o 'testcron.txt' -b 0 -qqqrr --title $'Perle SDS-2 TruePort' '/dev/tx0000' '/dev/ttyS0'

#./serial-latency-test.pl -c 10 --errors -o 'testcron.txt' -b 0 -qqqrr --title $'Advantech Adam-4571L AdvTTY' '/dev/ttyADV6' '/dev/ttyUSB0'
#./serial-latency-test.pl -c 10 --errors -o 'testcron.txt' -b 0 -qqqrr --title $'Moxa NPort 5110 npreal2' '/dev/ttyr00' '/dev/ttyUSB0'

#./serial-latency-test.pl -c 10 --errors -o 'testcron.txt' -b 0 -qqqrr --title $'Comtrol DeviceMaster RTS 1P NS-Link' '/dev/ttySI0' '/dev/ttyUSB0'
#./serial-latency-test.pl -c 10 --errors -o 'testcron.txt' -b 0 -qqqrr --title $'Comtrol DeviceMaster RTS 1P' '192.168.50.244,8000,TCP' '/dev/ttyUSB0'

./serial-latency-test.pl -c 10 --errors -o 'testcron.txt' -b 0 -qqqrrr --rand-reverse --title $'Digi PortServer TS 4 RealPort' '/dev/ttyaf00' '/dev/ttyS0'
./serial-latency-test.pl -c 10 --errors -o 'testcron.txt' -b 0 -qqqrrr --rand-reverse --title $'Digi PortServer TS 2 RealPort' '/dev/ttyag00' '/dev/ttyUSB0'
# These won't work so long as they are attached to dgrp RealPort
./serial-latency-test.pl -c 10 --errors -o 'testcron.txt' -b 9600 -qqqrrr --rand-reverse --title $'Digi PortServer TS 4 RealPort' '192.168.50.107,2101,TCP' '/dev/ttyS0'
./serial-latency-test.pl -c 10 --errors -o 'testcron.txt' -b 9600 -qqqrrr --rand-reverse --title $'Digi PortServer TS 2 RealPort' '192.168.50.148,2101,TCP' '/dev/ttyUSB0'
