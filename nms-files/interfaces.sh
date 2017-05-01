#!/bin/sh

set -ex

[ ! -z "${IPADDRESS}" ]
[ ! -z "${IFW1_DMZ_IP}" ]
[ ! -z "${DNSFW1_IP}" ]

gw=$(dirname "${IFW1_DMZ_IP}")
dns1=$(dirname "${DNSFW1_IP}")

MASK=$(basename "${IPADDRESS}")
ADDR=$(echo ${IPADDRESS}|sed 's@/'${MASK}'@@')

sed -e 's/BOOTPROTO=.*/BOOTPROTO=none/' -i /etc/sysconfig/network-scripts/ifcfg-eth0
{
  printf 'IPADDR0=%s\n' "${ADDR}"
  printf 'PREFIX0=%s\n' "${MASK}"
  printf 'GATEWAY0=%s\n' "${gw}"
  printf 'DNS1=%s\n' "${dns1}"
} >> /etc/sysconfig/network-scripts/ifcfg-eth0
