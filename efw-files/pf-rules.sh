#!/bin/sh

set -e

# okay I was mean and took advantage of set -e
[ ! -z "${CABLE_MODEM_IP}" ]
[ ! -z "${ADMIN_NETS}" ]

# negations in the <martians> table
visitors="${visitors} ${CABLE_MODEM_IP}/32"

{
  # tables
  printf 'table <martians> persist {\n'
  for x in 0.0.0.0/8 10.0.0.0/8 100.64.0.0/10 127.0.0.0/8 169.254.0.0/16 \
           172.16.0.0/12 192.0.0.0/24 192.0.2.0/24 192.168.0.0/16 192.18.0.0/15 \
           198.51.100.0/24 203.0.113.0/24
   do
     printf ' %s\n' "${x}"
   done
  for x in ${visitors} ; do
   printf ' !%s' "${x}"
  done
  printf '}\n'

  printf 'table <admin> persist {\n'
  printf ' %s ' "${ADMIN_NETS}"
  printf '}\n'
  printf '\n'

  # skips
  printf 'set skip on lo\n'
  printf '\n'

  # diverts
  printf 'anchor "ftp-proxy/*"\n'
  printf 'pass in on transit inet proto tcp to port ftp flags S/SA modulate state divert-to 127.0.0.1 port 8021\n'
  printf '\n'

  # NATs
  printf 'match out on egress inet from !(egress:network) to any nat-to (egress:0)\n'
  printf '\n'

  # filter start
  printf 'block return\n'
  printf '\n'

  # antispoof
  printf 'block in quick from urpf-failed label uRPF\n'
  printf '\n'

  # filter continue
  printf 'pass in on egress inet proto icmp to (egress) icmp-type echoreq\n'
  printf 'block in quick on transit from !<admin> to %s\n' "${CABLE_MODEM_IP}" 
  printf 'pass on transit proto tcp flags S/SA modulate state\n'
  printf 'pass on transit proto { icmp, udp } keep state\n'
  printf 'pass out on egress to !<martians>\n'
} > /etc/pf.conf

pfctl -n -f /etc/pf.conf
