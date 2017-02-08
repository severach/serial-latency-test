@ECHO OFF

REM UDP and SSL require specific settings to work. Full notes are in test.sh

REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -q --title \"\tOnboard Serial Port\t" "COM1"
REM The timing is too erratic to use the FTDI in Windows 10.
REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -q --title \"\tFTDI FT232 USB\t" "COM3"
REM I won't test the Prolific 2303. Drivers are way too hard to find and it's too hard to figure out if these are fakes.

REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -qrr --title "\"1.8.28\"\tPassport PNI ESport 101\tCOM1" "192.168.50.122,4000" "COM1"
REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -qrr --title "\"sw1.8.1/hw1\"\tB&B Smartworkx VESP211\tCOM1" "192.168.50.174,4000" "COM1"
REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -qrr --title "\"1.70\"\tAdvantech Adam 4571L-CE\tCOM1" "192.168.50.222,5300" "COM1"
REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -qrr --title "\"4.8\"\tPerle IOLan SDS 2 (ML)\tCOM1" "192.168.50.181,10001,TCP" "COM1"
REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -qrr --title "\"4.8\"\tPerle IOLan SDS 2 TruePort (ML)\tCOM1" "COM10" "COM1"
REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -qrr --title "\"4.8\"\tPerle IOLan SDS 2 (ML)\tCOM1" "192.168.50.181,10001,SSL" "COM1"
 
REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -qrr --title "\"10.16\"\tComtrol DeviceMaster RTS ARM7\tCOM1" "192.168.50.244,8000" "COM1"
REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -qrr --title "\"10.16\"\tComtrol DeviceMaster RTS ARM7 NSLink\tCOM1" "COM3" "COM1"
REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -qrr --title "\"10.16\"\tComtrol DeviceMaster RTS ARM7 NSLink SSL\tCOM1" "COM3" "COM1"
REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -qrr --title "\"10.16\"\tComtrol DeviceMaster RTS ARM7\tCOM1" "192.168.50.244,8000,SSL" "COM1"

REM Check the first 3 boxes. Target IP Address: 192.168.50.10, Target Port: 7000, Source Port: 0
REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -qrr --title "\"10.16\"\tComtrol DeviceMaster RTS ARM7\tCOM1" "192.168.50.244,7000,UDP/2" "COM1"

REM Check all 4 UDP boxes. Leave the numeric boxes blank.
REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -qrr --title "\"10.16\"\tComtrol DeviceMaster RTS ARM7\tCOM1" "192.168.50.244,7000,UDP" "COM1"

REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -qrr --title "\"82000747_W1\"\tDigi Portserver TS 1\tCOM1" "192.168.50.190,2101" "COM1"

REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -qrr --title "\"82000747_W1\"\tDigi Portserver TS 1 Realport\tCOM1" "COM2" "COM1"
REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -qrr --title "\"82000747_W1\"\tDigi Portserver TS 1 Realport SSL\tCOM1" "COM2" "COM1"

REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -qrr --title "\"2.6\"\tMoxa NPort 5110\tCOM1" "192.168.50.128,4001" "COM1"
REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -qrr --title "\"2.6\"\tMoxa NPort 5110 NPReal 1.22\tCOM1" "COM2" "COM1"
REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -qrr --title "\"2.6\"\tMoxa NPort 6150\tCOM1" "192.168.50.196,4001,UDP/2" "COM1"
REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -qrr --title "\"2.6\"\tMoxa NPort 6150\tCOM1" "192.168.50.196,4001,UDP" "COM1"
REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -qrr --title "\"2.6\"\tMoxa NPort 6150\tCOM1" "192.168.50.196,4001,SSL" "COM1"

REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -qrr --title "\"6.11.0.0\"\tLantronix UDS1100 CPR 4.3.0.3 RFC2217\tCOM1" "COM2" "COM1"
REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -qrr --title "\"6.11.0.0\"\tLantronix UDS1100\tCOM1" "192.168.50.150,10001" "COM1"

REM perl serial-latency-test.pl -c 100 -o "testswin.txt" -qrr --title "\"3.6/4\"\tLantronix MSS1-T\tCOM1" "192.168.50.135,3001" "COM1"
