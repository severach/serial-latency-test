#!/usr/bin/perl

# Latency test for serial device servers via TCP, UDP, or tty/COM.
# Send one byte, wait for it to return.
# Used with cron this also tests reliability of hardware and tty drivers with OS versions.
# Compatible with Linux, Windows Strawberry Perl

# Copyright (C) 2017 Chris Severance
# https://github.com/severach/serial-latency-test

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

###

# Todo: Clean up pass
# Todo: I won't implement UDP broadcast. Risking out of order packets with UDP is bad enough without filling the network with broadcast packets.

# Usage: bench-slt.pl [options] port1 [port2]
# Specify one port for use with loopback connector.
# Specify two ports to transfer through two devices.
# Port type:
#    /dev/tty* or COM for tty emulation. Use COMx for Windows.
#    192.168.50.100,8000 or 192.168.50.100,8000,TCP for unencrypted TCP socket
#    192.168.50.100,8000,SSL for encrypted TCP socket
#    192.168.50.100,8000,UDP for unencrypted UDP socket. SSL encryption is not available with UDP. Many servers do not support this.
#    192.168.50.100,8000,UDP/2 "by 2" for separate UDP client and server sockets.

# For most accurate results test a serial device server connected to a real COM port with known and consistent delay.
# Test both directions through the serial device server separately.
# For fair testing units should be set for the lowest latency available and 9600,N81,none.
# Other latency settings should be tested to see if there are any noticable effects.

# Rewritten then unified with Python code bench.py found in:

# White Paper
# An overview of network serial port servers,
# the potential impact of communications
# latency, and the results of a Comtrol latency
# benchmark measuring the elapsed time
# required to transmit and receive serial data
# between a networked Personal Computer and
# an Ethernet-attached serial port server.

# Benchmark Prepared and Executed By:
# Grant Edwards, Sr. Principal Engineer, Comtrol Corporation
# David Boldt , Sr. Technical Consultant, Comtrol Corporation
# (C) 2003 by Comtrol Corporation

# Original Comtrol options
# -q Print only the final results -- don't print results from each iteration.
# -c <count> Run <count> iterations [default 100]
# -d <delay> Wait for <delay>ms between reading data and next write. [default 100]
# -b <baud> Set port to <baud> bits per second. [default 9600]
# -i <time> When reading, use an inter-character timeout of <time>ms [default 2]
# -s <size> Use a block size of <size>bytes. [default 1]
# -t <time> Use a total read timeout of <time>ms. [default 2000]

# See below for more options.

# The benchmark test was executed using the following parameters:
# inter-character timeout: 2ms
# total read timeout: 2,000ms
# iteration delay : 100ms
# baud rate : 9,600bps
# block size: 1 byte
# number of iterations : 10,0000
# [All parameters are default values except iteration count.]

# 10,0000 looks like a misprint. I think the number of iterations was 10,000 which is already excessive and unnecessary.
# The averages on Linux are consistent from 10 up. Windows needs at least 100 to get a good average.

use strict;
use warnings;

use IO::Socket::INET;
use IO::Select;
use Socket qw(IPPROTO_TCP TCP_NODELAY);
use Time::HiRes qw(gettimeofday tv_interval usleep);
use Getopt::Long qw{:config bundling no_ignore_case no_auto_abbrev no_getopt_compat no_permute require_order};
use IO::Socket::SSL;

my $g_OS="$^O";
if ("$^O" eq 'MSWin32') {
  eval "use Win32::SerialPort qw( :PARAM :STAT 0.07 )" ;
  eval "use Win32 qw(GetOSName)";
  my ($Win10,$Business32bit)=Win32::GetOSName();
  $g_OS=$Win10;
} else {
  eval "use Device::SerialPort qw( :PARAM :STAT 0.07 )";
  #eval "use POSIX qw(osvers)"; # Not even remotely useful! config{osvers} even less so.
  $g_OS.=`uname -r`;
  chomp($g_OS);
}

#use Net::SSLeay;
#$Net::SSLeay::ssl_version = 3;  # Insist on SSLv3
#$IO::Socket::SSL::DEBUG=10;
#printf "perl=%s IO:Socket::SSL=%s Net::SSLeay=%s openssl=%x\n", $^V, $IO::Socket::SSL::VERSION, $Net::SSLeay::VERSION, Net::SSLeay::OPENSSL_VERSION_NUMBER();

my $opt_Count=100;
my $opt_Delayms=100;
my $opt_BlockSize=1;
my $opt_Baud=9600; # Set by the device for TCP connections. If zero a random baud rate 300-115200 will be picked for you. Only useful if baud can be set for both ports.
my $opt_ICTimeout=2.0;
my $opt_Timeoutms=2000;
my $opt_Quiet=0;

# Additional non Comtrol options

my $opt_Reverse=0;
# -r reverse the two ports for easy testing both ways. Alters the csv output.
# Specify twice -rr to run forwards then reversed.
# Specify thrice -rrr to run both ways with half duplex dead time measurements.
my $opt_Title='';   # --title outputs in tabbed CSV with title followed by TX or RX from -r. Can contain tab characters, $'\t' for Linux, "\t" for Windows. You probably want -q with this.
my $opt_Output='';  # -o output file to append CSV. If the file doesn't exist the CSV header will be written as the first line. Ignored without -t or --errors.
my $opt_Errors=0;   # --errors output errors to CSV. Good for long term reliability testing via cron.
my $opt_Retry=0;    # --retry n resend test block n times if missed. Used to get test info from buggy serial servers. If you need to use this your serial server is dropping characters and is broken.
my $opt_RandReverse=0; # --rand-reverse 50% chance that port1 and port2 will be reversed.

GetOptions(
"count|c=i"     => \$opt_Count,
"delay|d=i"     => \$opt_Delayms,
"size|s=i"      => \$opt_BlockSize,
"baud|b=i"      => \$opt_Baud,
"interchar-timeout|i=i" => \$opt_ICTimeout,
"timeout|t=i"   => \$opt_Timeoutms,
"quiet|q+"      => \$opt_Quiet, # specify more to make quieter
"reverse|r+"    => \$opt_Reverse,
"title=s"       => \$opt_Title,
"output|o=s"    => \$opt_Output,
"errors"        => \$opt_Errors,
"retry=i"       => \$opt_Retry,
"rand-reverse"  => \$opt_RandReverse,
) or die("Error in command line arguments\n");

my $args_portcount=scalar @ARGV;
if ($args_portcount < 1 or $args_portcount > 2) {
  die("need 1 or 2 ports\n");
}
if ($^O eq 'MSWin32') {
  if ($args_portcount==2 and lc $ARGV[0] eq lc $ARGV[1]) {
    $args_portcount=1;
  }
} else {
  if ($args_portcount==2 and $ARGV[0] eq $ARGV[1]) {
    $args_portcount=1;
  }
}
if ($args_portcount == 1 and ($opt_Reverse or $opt_RandReverse)) {
  die("reverse options are not permitted with only $args_portcount port\n");
}
if ($opt_Reverse == 3 and $opt_BlockSize != 1) {
  die("reverse half duplex dead time measurement must be used with blocksize 1\n");
}

if ($opt_BlockSize < 1)  { $opt_BlockSize = 1;}
if ($opt_Count     < 10) { $opt_Count     = 10;} # At 1 the SD won't calculate properly
if ($opt_Delayms   < 0)  { $opt_Delayms   = 0;}
if (not $opt_Quiet) {
  print "$^O\n";
  print "Blocksize=$opt_BlockSize\n";
  print "Count=$opt_Count\n";
  print "Delay=${opt_Delayms}ms\n";
}
if ($opt_Baud == 0) {
  my @ar=(300,1200,2400,9600,19200,38400,57600,115200);
  $opt_Baud=$ar[int(rand(scalar @ar))];
}
if ($opt_RandReverse) {
  $opt_RandReverse=int(rand(2));
}

if ($^O eq 'MSWin32') {
  $opt_Title=~ s/\\t/\t/g;
}

# http://stackoverflow.com/questions/12644322/how-to-write-the-current-timestamp-in-a-file-perl
sub getLoggingTime {
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
  return sprintf ( "%04d/%02d/%02d %02d:%02d:%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec);
}
my $g_logtime=getLoggingTime();

my $fOutput=*STDOUT;
if (length($opt_Title) or $opt_Errors) {
  if (length($opt_Output)) {
    if (not -f $opt_Output) {
      open($fOutput,">",$opt_Output) or die();
      print $fOutput "OS\tLogtime\tBaud\tBS\tCount\tRuntime\tcps\t",$opt_Title,"\tdir\tTX\tRX\tmin\tmean\tmax\tSD\thmin\thmean\thmax\thSD\ttxod\trxod\ttxcd\trxcd\n";
    } else {
      open($fOutput,">>",$opt_Output) or die();
    }
  }
}

# Messages are expected to end with \n
sub logdie {
  my $s=shift();
  print $fOutput $g_logtime." ".$s if ($opt_Errors);
  die($s)
}

# All connection types are expected to block
sub openPort {
  my $arg_ct_s=shift();
  my $arg_rx=shift();

  my $ct_handle;
  if (index($arg_ct_s,",") > -1) {
    my @ar=split(/,/,$arg_ct_s);
    # logdie("not enough TCP parms") if (scalar @ar <= 1); # This can't happen. It's tried as a serial port.
    push(@ar,"TCP") if (scalar @ar == 2);
    logdie("too many TCP parms\n") if (scalar @ar > 3);
    logdie("HOST,PORT is required\n") if (length($ar[0]) == 0 or length($ar[1]) == 0);
    $arg_ct_s=$ar[0].":".$ar[1];
    if (lc $ar[2] eq "ssl") {
      $ct_handle = new IO::Socket::SSL (
        PeerHost => $ar[0],
        PeerPort => $ar[1],
        SSL_verify_mode => SSL_VERIFY_NONE, # Some serial servers do not have certs in them.
        SSL_version => 'SSLv2/3', # which auto-negotiates between SSLv2 and SSLv3.
        #SSL_version => 'SSLv2', # not available
        #SSL_version => 'SSLv3', # not available
        #SSL_version => 'TLSv1',
        #SSL_version => 'TLSv1_1',
        #SSL_version => 'TLSv1_2',
      ) || logdie("cannot connect to SSL socket $arg_ct_s $!,$SSL_ERROR\n");
      $ct_handle->setsockopt(IPPROTO_TCP, TCP_NODELAY, 1);
      printf("Cipher=%s Version=%s(%d)\n",$ct_handle->get_cipher(),$ct_handle->get_sslversion(),$ct_handle->get_sslversion_int()) if ($opt_Quiet < 3);
      return ($ct_handle,1,"SSL/".$ct_handle->get_cipher()."/".$ct_handle->get_sslversion(),0);
    } elsif (lc $ar[2] eq 'tcp' or lc $ar[2] eq 'udp' or lc $ar[2] eq 'udp/2' ) {
      if ($arg_rx and lc $ar[2] eq 'udp/2') {
        $ct_handle = new IO::Socket::INET (
          LocalPort => $ar[1],
          Proto => 'udp',
          Blocking => 1,
          Timeout => 2,
        ) || logdie("cannot create server connect to $ar[2] socket $arg_ct_s $!\n");
        $ct_handle->setsockopt(IPPROTO_TCP, TCP_NODELAY, 1);
        return ($ct_handle,1,$ar[2],1);
      } else {
        my $reopen=0;
        my $proto=$ar[2];
        if (lc $proto eq 'udp/2') {
          $proto='udp';
          $reopen=1;
        }
        $ct_handle = new IO::Socket::INET (
          PeerHost => $ar[0],
          PeerPort => $ar[1],
          Proto => $proto,
          Blocking => 1,
          Timeout => 2,
        ) || logdie("cannot connect to $ar[2] socket $arg_ct_s $!\n");
        $ct_handle->setsockopt(IPPROTO_TCP, TCP_NODELAY, 1);
        return ($ct_handle,1,$ar[2],$reopen);
      }
    } else {
      logdie("Unknown transport $ar[2] socet $arg_ct_s\n");
    }
  } else {
    if ($^O eq 'MSWin32') {
      $ct_handle = new Win32::SerialPort ($arg_ct_s, 0)
         || logdie("Can't open serial $arg_ct_s: $!\n");
    } else {
      $ct_handle = new Device::SerialPort ($arg_ct_s, 0)
         || logdie("Can't open serial $arg_ct_s: $!\n");
    }
    $ct_handle->baudrate($opt_Baud);
    $ct_handle->parity("none");
    $ct_handle->databits(8);
    $ct_handle->stopbits(1);
    $ct_handle->write_settings() || undef $ct_handle;
    $ct_handle->can_interval_timeout($opt_ICTimeout);
    $ct_handle->can_total_timeout($opt_Timeoutms);
    #$ct_handle->stty_icanon(1);
    $ct_handle->read_const_time(0);
    $ct_handle->read_char_time(0);
    return ($ct_handle,0,(($^O eq 'MSWin32')?"COM":"tty"),0);
  }
}

sub SetBlock {
  my $arg_handle=shift();
  my $arg_issocket=shift();
  my $arg_seconds=shift();
  if ($arg_issocket) {
    if ("$^O" eq 'MSWin32') {
      # We try, but it doesn't work in Windows. We use can_read() instead.
      $arg_handle->setsockopt(SOL_SOCKET, SO_RCVTIMEO, pack( 'L!', int($arg_seconds*1000) ) ) || logdie("can't set SO_RCVTIMEO\n");
    } else {
      $arg_handle->setsockopt(SOL_SOCKET, SO_RCVTIMEO, pack( 'l!l!', int($arg_seconds), 1000000*($arg_seconds-int($arg_seconds)) ) ) || logdie("can't set SO_RCVTIMEO\n");
    }
  } else {
    $arg_handle->read_const_time($arg_seconds*1000);
  }
}

my $txfile=$ARGV[$opt_RandReverse-0];
my $txopendelay=[gettimeofday()];
my ($ct_txhandle,$txissocket,$txtype,$txreopen)=openPort($txfile,0);
$txopendelay = tv_interval($txopendelay, [gettimeofday()]);
print "TX open delay=$txopendelay\n" if ($opt_Quiet <= 1);
my ($ct_rxhandle,$rxissocket,$rxtype,$rxreopen);

my $rxopendelay=-1;
my $rxfile;
if ($args_portcount == 1) {
  $rxfile=$txfile;
  ($ct_rxhandle,$rxissocket,$rxtype,$rxreopen)=($ct_txhandle,$txissocket,$txtype,$txreopen);
} else {
  $rxfile=$ARGV[$opt_RandReverse-1];
  $rxopendelay=[gettimeofday()];
  ($ct_rxhandle,$rxissocket,$rxtype,$rxreopen)=openPort($rxfile,1);
  $rxopendelay = tv_interval($rxopendelay, [gettimeofday()]);
}

my @loglines=();
sub logout {
  my $l;
  foreach $l (@loglines) {
    print $fOutput $l,"\t",$_[0],"\t",$_[1],"\n";
    $txopendelay=-1;
    $rxopendelay=-1;
  }
  @loglines=();
}

my $pass;
my $pass1=0;
my $pass2=0;
if ($opt_Reverse == 1) {
  $pass1=1; $pass2=1;
  $txreopen=0;
  $rxreopen=0;
} elsif ($opt_Reverse >= 2) {
  $pass1=0; $pass2=1;
}
endpass: for ($pass=$pass1; $pass<=$pass2; $pass++) {
  my $passTXRXLP=($args_portcount==1?"LP":(($opt_RandReverse-$pass)?"RX":"TX"));
  if ($pass == 1) {
    ($ct_txhandle,$ct_rxhandle)=($ct_rxhandle,$ct_txhandle);
    ($txissocket,$rxissocket)=($rxissocket,$txissocket);
    ($txtype,$rxtype)=($rxtype,$txtype);
    ($txreopen,$rxreopen)=($rxreopen,$txreopen);
    ($txfile,$rxfile)=($rxfile,$txfile);
    if ($rxreopen) {
      #printf "reopn $pass $txreopen $rxreopen $rxfile\n";
      my $txclosedelay=[gettimeofday()];
      $ct_rxhandle->close();
      $txclosedelay = tv_interval($txclosedelay, [gettimeofday()]);
      logout($txclosedelay,-1);
      $rxopendelay=[gettimeofday()];
      ($ct_rxhandle,$rxissocket,$rxtype,$rxreopen)=openPort($rxfile,1);
      $rxopendelay = tv_interval($rxopendelay, [gettimeofday()]);
    }
    ($txopendelay,$rxopendelay)=($rxopendelay,$txopendelay);
  }
  logout(-1,-1);

  # Knuth Welford one pass standard deviation
  my $KW_n=0;
  my $KW_mean=0.0;
  my $KW_M2=0.0;
  my $KW_delta;
  my $KW_delta2;

  my $KW_hdn=0;
  my $KW_hdmean=0.0;
  my $KW_hdM2=0.0;
  my $KW_hddelta;
  my $KW_hddelta2;

  # Comtrol variables
  my $ct_txTime;
  my $ct_rxTime;
  my $ct_loops;
  my $ct_txdata;
  my $ct_rxdata;
  my $ct_data;
  #my $ct_txcount;
  #my $ct_deltams;
  my $ct_deltamsmin=9999999999; # Comtrol code didn't do it this way
  my $ct_deltamsmax=0;

  my $hddeltams;
  my $hddeltamsmin=9999999999;
  my $hddeltamsmax=0;

  SetBlock($ct_rxhandle,$rxissocket,0.25);
  my $rxlist;
  if ($rxissocket) {
    $rxlist=IO::Select->new();
    $rxlist->add($ct_rxhandle);
  }
  my $txlist;
  if ($txissocket) {
    $txlist=IO::Select->new();
    $txlist->add($ct_txhandle);
  }
  do {
    $ct_data="";
    if ($rxissocket) {
      print "Clearing buffer in serial server.\n" if (!$opt_Quiet);
      if ($rxlist->can_read(0.25)) {
        #$ct_rxhandle->recv($ct_data, 64, 0); # Not compatible with SSL
        $ct_rxhandle->sysread($ct_data, 64);
      }
    } else {
      print "Clearing tty buffer.\n" if (!$opt_Quiet);
      (undef,$ct_data)=$ct_rxhandle->read(64);
    }
    print "Discard=$ct_data\n" if (length($ct_data) and not $opt_Quiet);
  } until (length($ct_data) == 0);
  if ($args_portcount == 2) {
    do {
      if ($txissocket) {
        print "Clearing buffer in serial server.\n" if (!$opt_Quiet);
        if ($txlist->can_read(0.25)) {
          #$ct_txhandle->recv($ct_data, 64, 0); # Not compatible with SSL
          $ct_txhandle->sysread($ct_data, 64);
        }
      } else {
        print "Clearing tty buffer.\n" if (!$opt_Quiet);
        (undef,$ct_data)=$ct_txhandle->read(64);
      }
      print "Discard=$ct_data\n" if (length($ct_data) and not $opt_Quiet);
    } until (length($ct_data) == 0);
  }

  print "Start test.\n" if (not $opt_Quiet);

  SetBlock($ct_txhandle,$txissocket,$opt_Timeoutms/1000);
  SetBlock($ct_rxhandle,$rxissocket,$opt_Timeoutms/1000);
  my $rxremain;
  my $runtime=[gettimeofday()];
  for ($ct_loops = 0; $ct_loops<=$opt_Count; $ct_loops++) {

    do {
      # Send
      $ct_txdata = chr(65+($ct_loops & 31)) x $opt_BlockSize;
      my $ct_txcount;
      $ct_rxTime=0;
      $ct_txTime=[gettimeofday()];
      if ($txissocket) {
        $ct_txcount = $ct_txhandle->syswrite($ct_txdata);
        logdie("tx socket is dead\n") unless $ct_txhandle -> connected();
      } else {
        $ct_txcount=$ct_txhandle->write($ct_txdata);
      }
      if ($ct_txcount < $opt_BlockSize) {
        printf "Only sent $ct_txcount of $opt_BlockSize\n";
      }

      # Receive
      $rxremain=$opt_BlockSize;
      $ct_rxdata="";
      if ($rxissocket) {
        if ($rxlist->can_read($opt_Timeoutms/1000)) {
          #$ct_rxhandle->recv($ct_rxdata, $rxremain, 0); # Not compatible with SSL
          $ct_rxhandle->sysread($ct_rxdata, $rxremain);
        }
        #logdie("rx socket is dead\n") unless $ct_rxhandle -> connected(); # Doesn't work for UDP server sockets
      } else {
        (undef,$ct_rxdata)=$ct_rxhandle->read($rxremain);
      }
      $rxremain -= length($ct_rxdata);
      if (length($ct_rxdata)) {
        # This line measures start send to start receive. This lessens the time penalty from low baud rates.
        $ct_rxTime=[gettimeofday()];
        while ($rxremain) {
          if ($rxissocket) {
            #$ct_rxhandle->recv($ct_data, $rxremain, 0); # Not compatible with SSL
            $ct_rxhandle->sysread($ct_data, $rxremain);
          } else {
            (undef,$ct_rxdata)=$ct_rxhandle->read($rxremain);
          }
          $rxremain -= length($ct_data);
          $ct_rxdata .= $ct_data;
        }
      }
    } until($rxremain == 0 or $opt_Retry-- <= 0);
    # This line will replicate the timing in the Comtrol .py file
    #$ct_rxTime=[gettimeofday()] if ($ct_rxTime == 0);
    if (length($ct_rxdata) == 0) {
      print $fOutput $g_logtime." Pass $pass-$passTXRXLP no response. Did you forget a loopback adapter or lose connection?\n";
      last endpass; # We want $txclosedelay when this happens.
    }
    my $ct_deltams = tv_interval($ct_txTime, $ct_rxTime)*1000;
    if ($ct_rxdata ne $ct_txdata) {
      print "Response($ct_loops)=$ct_rxdata\n"; # We don't send any hex.
      print "Sent    ($ct_loops)=$ct_txdata\n";
      logdie("Response and sent mismatched\n");
    }
    if ($opt_Reverse == 3 and $opt_BlockSize == 1) {
      # Send through rx port
      my $ct_rxcount;
      my $hdtime=[gettimeofday()]; # I think it would not be more accurate to use $ct_rxTime here. I'm looking for the minimum time delay. I don't want any extra time delay that real applications have preparing the half duplex response. 
      if ($rxissocket) {
        $ct_rxcount = $ct_rxhandle->syswrite($ct_rxdata);
        logdie("rx socket is dead\n") unless $ct_rxhandle -> connected();
      } else {
        $ct_rxcount=$ct_rxhandle->write($ct_rxdata);
      }
      if ($ct_rxcount < $opt_BlockSize) {
        printf "Only sent $ct_rxcount of $opt_BlockSize\n";
      }

      # Receive through tx port
      if ($txissocket) {
        if ($txlist->can_read($opt_Timeoutms/1000)) {
          #$ct_txhandle->recv($ct_txdata, $txremain, 0); # Not compatible with SSL
          $ct_txhandle->sysread($ct_txdata, $opt_BlockSize);
        }
        #logdie("tx socket is dead\n") unless $ct_txhandle -> connected(); # Doesn't work for UDP server sockets
      } else {
        (undef,$ct_txdata)=$ct_txhandle->read($opt_BlockSize);
      }

      # We don't do the extra buffering here so we can only work with block size 1. Besides this code would need to be multi threaded to be accurate at block size > 1.

      $hddeltams = tv_interval($hdtime, [gettimeofday()])*1000;

      if ($ct_rxdata ne $ct_txdata) {
        print "Response($ct_loops)=$ct_txdata\n"; # We don't send any hex.
        print "Sent    ($ct_loops)=$ct_rxdata\n";
        logdie("Pass $pass-$passTXRXLP Response and sent mismatched for half duplex test\n");
      }
    }
    print STDERR $ct_rxdata if ($opt_Quiet == 1 and $opt_BlockSize == 1);

    # Discard the first data point. It is faster for network connections.
    if ($ct_loops) {
      $KW_n++;
      $KW_delta=$ct_deltams-$KW_mean;
      $KW_mean += $KW_delta/$KW_n;
      $KW_delta2 = $ct_deltams-$KW_mean;
      $KW_M2 += $KW_delta*$KW_delta2;

      $ct_deltamsmin=$ct_deltams if ($ct_deltamsmin>$ct_deltams);
      $ct_deltamsmax=$ct_deltams if ($ct_deltamsmax<$ct_deltams);

      if ($opt_Reverse == 3 and $opt_BlockSize == 1) {
        $KW_hdn++;
        $KW_hddelta=$hddeltams-$KW_hdmean;
        $KW_hdmean += $KW_hddelta/$KW_hdn;
        $KW_hddelta2 = $hddeltams-$KW_hdmean;
        $KW_hdM2 += $KW_hddelta*$KW_hddelta2;

        $hddeltamsmin=$hddeltams if ($hddeltamsmin>$hddeltams);
        $hddeltamsmax=$hddeltams if ($hddeltamsmax<$hddeltams);
        printf "%d %5.1fms HD=%5.1fms\n",$ct_loops,$ct_deltams,$hddeltams if (!$opt_Quiet);
      } else {
        printf "%d %5.1fms\n",$ct_loops,$ct_deltams if (!$opt_Quiet);
      }
    }
    usleep($opt_Delayms*1000) if ($opt_Delayms);
  }
  $runtime = tv_interval($runtime, [gettimeofday()]);

  if (length($opt_Title)) {
    my $line=$g_OS."\t".$g_logtime."\t".$opt_Baud."\t".$opt_BlockSize."\t".$KW_n."\t".int($runtime+0.5)
         ."\t".int($opt_BlockSize*$KW_n/($runtime-$ct_loops*$opt_Delayms/1000.0))
         ."\t".$opt_Title."\t".$passTXRXLP."\t".$txtype."\t".$rxtype."\t"
         .sprintf("%.2f\t%.2f\t%.2f",$ct_deltamsmin,$KW_mean,$ct_deltamsmax)."\t".$KW_M2/($KW_n-1);
    if ($opt_Reverse == 3 and $opt_BlockSize == 1) {
      $line .= sprintf("\t%.2f\t%.2f\t%.2f",$hddeltamsmin,$KW_hdmean,$hddeltamsmax)."\t".$KW_hdM2/($KW_hdn-1);
    } else {
      $line .= "\t\t\t\t";
    }
    $line .= "\t".$txopendelay."\t".$rxopendelay;
    push (@loglines,$line); # the log line printer will append any available close delays
  } else {
    print("Count=",$KW_n," runtime=",int($runtime+0.5),"s cps=",int($opt_BlockSize*$KW_n/($runtime-$ct_loops*$opt_Delayms/1000.0))," min/mean/max=",sprintf("%.2f/%.2f/%.2f",$ct_deltamsmin,$KW_mean,$ct_deltamsmax),"ms std=",$KW_M2/($KW_n-1),"\n");
  }
}

if ($txissocket) {
  #$ct_txhandle->shutdown(2); # No can do with SSL
}
my $rxclosedelay=-1;
my $txclosedelay=[gettimeofday()];
$ct_txhandle->close();
$txclosedelay = tv_interval($txclosedelay, [gettimeofday()]);
print "TX close delay=$txclosedelay\n" if ($opt_Quiet <= 1);
if ($args_portcount == 2) {
  if ($rxissocket) {
    #$ct_rxhandle->shutdown(2); # No can do with SSL
  }
  $rxclosedelay=[gettimeofday()];
  $ct_rxhandle->close();
  $rxclosedelay = tv_interval($rxclosedelay, [gettimeofday()]);
}
logout($txclosedelay,$rxclosedelay);
