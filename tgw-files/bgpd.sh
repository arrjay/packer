#!/bin/sh

set -ex

[ ! -z "${AS_NUMBER}" ]
[ ! -z "${INTERNAL_EFW_IP}" ]

[ ! -z "${VMM_RANGE}" ]

rcv_cidr=$(basename ${INTERNAL_EFW_IP})
receiver=$(echo ${INTERNAL_EFW_IP}|sed 's@/'${rcv_cidr}'@@')

{
  printf 'AS %s\n' "${AS_NUMBER}"
  printf '\n'
  printf 'deny from any prefix { %s }\n\n' "${VMM_RANGE}"
  printf 'nexthop qualify via bgp\n\n'
  printf 'neighbor %s {\n' "${receiver}"
  printf ' remote-as %s\n' "${AS_NUMBER}"
  printf ' announce IPv4 unicast\n'
  printf ' ttl-security yes\n'
  printf '}\n'
} > /etc/bgpd.conf

chmod a-r /etc/bgpd.conf

bgpd -dn

rcctl enable bgpd
