@ECHO OFF

REM perl serial-latency-test.pl -c 10 --errors -o "testcron.txt" -b 0 -qqqrrr --title "Digi PortServer TS 4 RealPort 82000747_T1" "COM10" "COM1"
rem perl serial-latency-test.pl -c 10 --errors -o "testcron.txt" -b 9600 -qqqrrr --title "Lavalink ESL1" "128.0.0.162,4098,TCP" "COM1"
perl serial-latency-test.pl -c 10 --errors -o "testcron.txt" -b 9600 -qqqrrr --title "Digi One SP" "128.0.0.52,2101,TCP" "COM1"
