# Serial Latency Test

Many industries still use RS232, RS422, or RS485 serial ports. Network based serial device servers are a good choice and for many reasons may be the only choice. Many companies sell these devices and they are very expensive.

Because buyers have no way to test these devices other than to deploy them and wait for complaints, buyers do not know that many companies are producing substandard products. Because sellers don't have adequate testing methods they are releasing unreliable products. Sellers would provide reliable products if adequate tests were available.

Many serial based applications are latency sensitive. Too much, or even too little can cause problems. Buyers might switch brands and solve a problem without ever knowing what changed to solve the problem.

This is a test tool for serial ports of all types.

* Written in [Perl](https://www.perl.org/)
* Runs in Windows and Linux, possibly others.
* Logs output for long term comparison testing and QA
* Tests TCP, two variations of UDP, SSL, and tty/COM
* Tests are timed
* Tests the device servers with or without the supplied tty/COM drivers
* Test for regressions from OS or version changes
* Can be used to test OS serial port drivers
 
Windows and Linux examples are found in the provided sample scripts.

The original serial latency test `bench.py` is Copyright (C) 2003 [Comtrol Corporation](http://www.comtrol.com/). I needed more tests, more detail, and more platforms so I rewrote it.

### Windows Installation
Install [Perl](https://www.perl.org/get.html). This was developed with Linux and Strawberry Perl but ActiveState should work also.

Install serial port library
```
C:\>cpan
cpan>notest install Win32::SerialPort
cpan>exit
```
### Sample run
For Linux, use `/dev/ttyS0` instead of `COM1`.
```
C:\>perl serial-latency-test.pl COM1
Pass 0-LP no response. Did you forget a loopback adapter or lose connection?

C:\>perl serial-latency-test.pl -c 10 192.168.10.52,2101,TCP COM1
MSWin32
Blocksize=1
Count=10
Delay=100ms
TX open delay=0.006312
Clearing tty buffer.
Clearing buffer in serial server.
Start test.
1  16.0ms
2  13.8ms
3  15.4ms
4  13.2ms
5  14.8ms
6  12.5ms
7  16.1ms
8  12.0ms
9  15.6ms
10  13.3ms
Count=10 runtime=1s cps=55 min/mean/max=12.01/14.28/16.14ms std=2.27
```

### Linux Installation
Install Perl: Most distros provide Perl and it is probably already installed.

Install non core and non default libraries
#### [Arch Linux](https://www.archlinux.org/)
````
pacman --needed -S perl-io-socket-ssl perl-device-serialport
````
#### [CentOS](https://www.centos.org/)
````
yum install perl-IO-Socket-SSL
````
`perl-Device-SerialPort` is required and not available from the standard repos or EPEL.
#### [Fedora](https://getfedora.org/)
````
dnf install perl-Device-SerialPort perl-Time-HiRes
````
#### [Ubuntu](https://www.ubuntu.com/)
````
apt install libdevice-serialport-perl
````
