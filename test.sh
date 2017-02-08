#!/bin/bash
#./serial-latency-test.pl -c 10 -o 'tests.txt' -q --title $'\tOnboard Serial Port\t' '/dev/ttyS0'
#./serial-latency-test.pl -c 10 -o 'tests.txt' -q --title $'\tFTDI FT232 USB\t' '/dev/ttyUSB0'
./serial-latency-test.pl -c 10 -o 'tests.txt' -q --title $'\tFTDI FT232 USB\t' -b 300 '/dev/ttyUSB0'
#./serial-latency-test.pl -c 10 -o 'tests.txt' -q --title $'\tProlific PL2303 USB\t' '/dev/ttyUSB0'


#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"1.8.28"\tPassport PNI ESport 101\tFT232' '192.168.50.122,4000' '/dev/ttyUSB0'
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"3.0"\tB&B Electronics ESP902\tFT232' '192.168.50.113,4000' '/dev/ttyUSB0'


#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"sw1.7.0/hw2"\tB&B Smartworkx VESP211-232\tFT232' '192.168.50.173,4000' '/dev/ttyUSB0'
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"sw1.8.1/hw1"\tB&B Smartworkx VESP211\tFT232' '192.168.50.174,4000' '/dev/ttyUSB0'

# Send Unicast 192.168.50.10, 4000
# Receive Unicast 192.168.50.10, 4000
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"sw1.8.1/hw1"\tB&B Smartworkx VESP211\tFT232' '192.168.50.174,4000,UDP/2' '/dev/ttyUSB0'


#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"1.70"\tAdvantech Adam 4571L-CE\tFT232' '192.168.50.222,5300' '/dev/ttyUSB0'
# tty -> UDP does not work even with Peer for receiving data set up.
#./serial-latency-test.pl -c 10 -o 'tests.txt' -q --title $'"1.70"\tAdvantech Adam 4571L-CE\tFT232' '192.168.50.222,5300,UDP/2' '/dev/ttyUSB0'
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"1.70"\tAdvantech Adam 4571L-CE AdvTTY 2.1.0\tFT232' '/dev/ttyADV6' '/dev/ttyUSB0'


#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"4.8"\tPerle IOLan SDS 2 (ML)\tFT232' '192.168.50.181,10001,TCP' '/dev/ttyUSB0'
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"4.8"\tPerle IOLan SDS 2 (ONT)\tFT232' '192.168.50.181,10001' '/dev/ttyUSB0'
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"4.8"\tPerle IOLan SDS 2 (PMF-250ms)\tFT232' '192.168.50.181,10001' '/dev/ttyUSB0'
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"4.8"\tPerle IOLan SDS 2 TruePort 6.8 (ML)\tFT232' '/dev/tx0000' '/dev/ttyUSB0'

# Perle sent data does not return to same port. To make Perle UDP work you need two rules.
# Lan to Serial, 192.168.50.10-192.168.50.10, Any              # This allows the source to increase the souce port number.
# Serial to LAN, 192.168.50.10-192.168.50.10, Specific, 10001. # This makes Perle connect and send the data back to our waiting server.
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"4.8"\tPerle IOLan SDS 2 (ML)\tFT232' '192.168.50.181,10001,UDP/2' '/dev/ttyUSB0'

# Perle SDS Device Server does not supply default keys without which SSL is non functional.
# See manual, Configuring Security, Keys and Certificates.
# You must generate private keys and download them to the Perle with DeviceManager.
# http://stackoverflow.com/questions/10175812/how-to-create-a-self-signed-certificate-with-openssl
# openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
# DeviceManager, Tools, Advanced, Keys and Certificates...
#   Download SSL/TLS Private Key: key.pem
#   Download SSL/TLS Certificate: cert.pem
# Profile: TCP Sockets, [x] SSL/TLS, SSL/TLS Type: Server
# Reboot Perle device server to activate new keys.
# Error "SSL23_GET_SERVER_HELLO:unknown protocol" Type is set to Client. Change type to Server. This program only connects to SSL servers.
# Error "SSL23_GET_SERVER_HELLO:sslv3 alert handshake failure" There are no keys on the device server. Create and download keys.
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"4.8"\tPerle IOLan SDS 2 (ML)\tFT232' '192.168.50.181,10001,SSL' '/dev/ttyUSB0'

#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"10.16"\tDeviceMaster RTS ARM7\tFT232' '192.168.50.244,8000' '/dev/ttyUSB0'
# Change Rx Polling Period to reduce the return delay
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"10.16"\tDeviceMaster RTS ARM7 RxPoll=10ms\tFT232' '192.168.50.244,8000' '/dev/ttyUSB0'

# Check the first 3 boxes. Target IP Address: 192.168.50.10, Target Port: 7000, Source Port: 0
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"10.16"\tDeviceMaster RTS ARM7\tFT232' '192.168.50.244,7000,UDP/2' '/dev/ttyUSB0'

# Check all 4 UDP boxes. Leave the numeric boxes blank.
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"10.16"\tDeviceMaster RTS ARM7\tFT232' '192.168.50.244,7000,UDP' '/dev/ttyUSB0'

#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"10.16"\tDeviceMaster RTS ARM7\tFT232' '192.168.50.244,8000,SSL' '/dev/ttyUSB0'
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"10.16"\tDeviceMaster RTS ARM7 NPLink 7.15\tFT232' '/dev/ttySI0' '/dev/ttyUSB0'


#./serial-latency-test.pl -c 10 -o 'tests.txt' -q --title $'"82000747_W1"\tDigi Portserver TS 1\t' '192.168.50.190,2101'
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"82000747_W1"\tDigi Portserver TS 1\tFT232' '192.168.50.190,2101' '/dev/ttyUSB0'

# For this leave send data blank.
# This will not work without [x] Send data after the following... 100ms. The time delay defeats the purpose of using UDP.
# [x] Send data when... would probably also work with real patterned data.
# Force sending after 1 byte does not work.
#./serial-latency-test.pl -c 10 -o 'tests.txt' -q --title $'"82000747_W1"\tDigi Portserver TS 1 (100ms)\t' '192.168.50.190,2101,UDP'
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"82000747_W1"\tDigi Portserver TS 1 (100ms)\tFT232' '192.168.50.190,2101,UDP' '/dev/ttyUSB0'

# For this, send to: 192.168.50.10, UDP port 2101.
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"82000747_W1"\tDigi Portserver TS 1 (100ms)\tFT232' '192.168.50.190,2101,UDP/2' '/dev/ttyUSB0'

# Digi answers port 2601 as SSL but it doesn't seem to access the serial port on the TS 1. The UI does not advertise it. SSL through RealPort does work.
##./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"82000747_W1"\tDigi Portserver TS 1\tFT232' '192.168.50.190,2601,SSL' '/dev/ttyUSB0'


#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"2.6"\tMoxa NPort 5110\tFT232' '192.168.50.128,4001' '/dev/ttyUSB0'
# Destination IP address 1: Begin-End 192.168.50.10-192.168.50.10, Port 4001
# Works with more than one IP in a range too. It must be sending non Multicast.
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"2.6"\tMoxa NPort 5110\tFT232' '192.168.50.128,4001,UDP/2' '/dev/ttyUSB0'

# Dynamic Destination (*) Enable
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"1.14"\tMoxa NPort 6150\tFT232' '192.168.50.196,4001,UDP' '/dev/ttyUSB0'
# Destination Address 1 Begin: 192.168.50.10
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"1.14"\tMoxa NPort 6150\tFT232' '192.168.50.196,4001,UDP/2' '/dev/ttyUSB0'
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"1.14"\tMoxa NPort 6150\tFT232' '192.168.50.196,4001,TCP' '/dev/ttyUSB0'
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"1.14"\tMoxa NPort 6150\tFT232' '192.168.50.196,4001,SSL' '/dev/ttyUSB0'
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"1.14"\tMoxa NPort 6150 npreal2 1.18.49\tFT232' '/dev/ttyr00' '/dev/ttyUSB0'
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"1.14"\tMoxa NPort 6150 npreal2 1.18.49 SSL\tFT232' '/dev/ttyr00' '/dev/ttyUSB0'

#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"3.604/2.70"\tAtop Neteon GW312\tFT232' '192.168.50.167,4660,TCP' '/dev/ttyUSB0'
# Begin-End IP: 192.168.50.10-192.168.50.10, Port 4660
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"3.604/2.70"\tAtop Neteon GW312\tFT232' '192.168.50.167,4660,UDP/2' '/dev/ttyUSB0'

#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"6.11.0.0"\tLantronix UDS1100\tFT232' '192.168.50.150,10001,TCP' '/dev/ttyUSB0'
# UDP Datagram type 01, Local Port 10001, Remote Port 10001, Remote Host 192.168.50.10
#./serial-latency-test.pl -c 10 -o 'tests.txt' -qrr --title $'"6.11.0.0"\tALantronix UDS1100\tFT232' '192.168.50.150,10001,UDP/2' '/dev/ttyUSB0'

# Defective firmware requires --retry
#./serial-latency-test.pl --retry 1 -c 10 -o 'tests.txt' -qrr --title $'"3.6/4"\tLantronix MSS1-T\tFT232' '192.168.50.135,3001,TCP' '/dev/ttyUSB0'

#./serial-latency-test.pl --retry 1 -c 10 -o 'tests.txt' -qrr --title $'"5.8.0.5"\tLantronix UDS10\tFT232' '192.168.50.151,10001,TCP' '/dev/ttyUSB0'
#./serial-latency-test.pl --retry 1 -c 10 -o 'tests.txt' -qrr --title $'"5.8.0.7"\tLantronix UDS100\tFT232' '192.168.50.184,10001,TCP' '/dev/ttyUSB0'

# The Moxa DE-211 is only reliable serial -> network
#./serial-latency-test.pl --retry 0 -c 10 -o 'tests.txt' -qr --title $'"2.2"\tMoxa NPort Express DE-211\tFT232' '192.168.50.134,4001,TCP' '/dev/ttyUSB0'

./serial-latency-test.pl -c 10 -o 'tests.txt' -qrrr --title $'"6.01.01"\tLava Ether-Serial Link ESL1\tFT232' '192.168.50.155,4098,TCP' '/dev/ttyUSB0'
