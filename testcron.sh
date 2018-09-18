#!/bin/bash

set -u

# $1 = title
# $2 = /dev/tty1
# $3 = /dev/tty2
_fn_tty() {
  local _tty1="$2"
  local _tty2="$3"
  if [[ "${_tty1}" == /dev/* ]] && [[ "${_tty1}" != /dev/tty* ]] && [ -L "${_tty1}" ]; then
    _tty1="$(readlink -m "${_tty1}")"
  fi
  if [[ "${_tty2}" == /dev/* ]] && [[ "${_tty2}" != /dev/tty* ]] && [ -L "${_tty2}" ]; then
    _tty2="$(readlink -m "${_tty2}")"
  fi

  ./serial-latency-test.pl -c 10 --errors -o 'testcron.txt' -b 0 -qqqrr --title "$1 ${_tty1##*/} ${_tty2##*/}" "$2" "$3"
}

cd "$(dirname "$0")" # cron compatible
uptime="$(cut -d' ' -f1 '/proc/uptime')" # do we need LC_ALL=C
uptime="${uptime%%.*}"
if [ "$(pgrep -c "$(basename "$0")")" -lt 2 ] && [ "${uptime}" -ge 30 ]; then # "
  #_fn_tty $'Digi PortServer TS 2 RealPort' '/dev/ttyaf00' '/dev/ttyS0'
  #_fn_tty $'Perle SDS-2 TruePort' '/dev/tx0000' '/dev/ttyS0'

  _fn_tty $'Advantech Adam-4571L' '/dev/ttyADV6' '/dev/ttyMXUSB3'

  #_fn_tty $'Digi PortServer TS 4 RealPort' '/dev/ttyaf00' '/dev/ttyS0'
  #_fn_tty $'Digi PortServer TS 2 RealPort' '/dev/ttyag00' '/dev/ttyUSB0'
  # These won't work so long as they are attached to dgrp RealPort
  #_fn_tty $'Digi PortServer TS 4 TCP' '192.168.50.107,2101,TCP' '/dev/serial/by-id/usb-Digi_International_Edgeport_8_I00826195-0-if00-port0'
  _fn_tty $'Digi PortServer TS 4 RealPort' '/dev/ttyai00' '/dev/serial/by-id/usb-Digi_International_Edgeport_8_I00826195-0-if00-port0'
  #_fn_tty $'Digi PortServer TS 2 TCP' '192.168.50.148,2101,TCP' '/dev/serial/by-id/usb-Digi_International_Edgeport_8_I00826195-1-if00-port0'
  _fn_tty $'Digi PortServer TS 2 RealPort' '/dev/ttyah00' '/dev/serial/by-id/usb-Digi_International_Edgeport_8_I00826195-1-if00-port0'

  _fn_tty $'Comtrol DeviceMaster RTS 1P NS-Link' '/dev/ttySI0' '/dev/serial/by-id/usb-Digi_International_Edgeport_8_I00826195-3-if00-port1'
  #_fn_tty $'Comtrol DeviceMaster RTS 1P' '/dev/ttySI0' '/dev/ttyUSB6'
  #_fn_tty $'Advantech Adam-4571L AdvTTY' '/dev/ttyADV6' '/dev/ttyS1'

  #_fn_tty $'Digi One SP TCP' '192.168.50.136,2101,TCP' '/dev/ttyS0'
  _fn_tty $'Digi One SP RealPort' '/dev/ttyag00' '/dev/serial/by-id/usb-Digi_International_Edgeport_8_I00826195-1-if00-port1'
  _fn_tty $'Digi One IA RealPort' '/dev/ttyaj00' '/dev/ttyMXUSB6'

  _fn_tty $'Digi Neo PCIe 4p HD68' '/dev/ttyn1a' '/dev/serial/by-id/usb-Digi_International_Edgeport_8_I00826195-0-if00-port1'
  _fn_tty $'Digi Neo PCIe 4p HD68' '/dev/ttyn1b' '/dev/ttySNX0'
  _fn_tty $'Digi Neo PCIe 4p HD68 Moxa UPort 1650-8' '/dev/ttyn1c' '/dev/ttyMXUSB0'
  _fn_tty $'Digi Neo PCIe 4p HD68 Moxa UPort 1650-8' '/dev/ttyn1d' '/dev/ttyMXUSB1'
  _fn_tty $'Digi Neo PCIe 4p RJ45 Moxa UPort 1650-8' '/dev/ttyn2a' '/dev/ttyMXUSB2'

  _fn_tty $'Moxa 6150' '/dev/ttyr00' '/dev/serial/by-id/usb-Digi_International_Edgeport_8_I00826195-2-if00-port1'

#  _fn_tty $'Perle SDS-2 TruePort 4.9T6' '/dev/tx0000' '/dev/serial/by-id/usb-Digi_International_Edgeport_8_I00826195-2-if00-port0'
#  _fn_tty $'Perle SDS-2 TruePort 4.9T6' '/dev/tx0001' '/dev/serial/by-id/usb-Digi_International_Edgeport_8_I00826195-3-if00-port0'
fi
