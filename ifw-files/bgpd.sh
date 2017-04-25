#!/bin/sh

set -e

[ ! -z "${AS_NUMBER}" ]
[ ! -z "${INTERNAL_EFW_IP}" ]
[ ! -z "${BGP_ROUTER_ID}" ]

pkg_add sipcalc

rcv_cidr=$(basename ${INTERNAL_EFW_IP})
receiver=$(echo ${INTERNAL_EFW_IP}|sed 's@/'${rcv_cidr}'@@')

{
  printf 'AS %s\n' "${AS_NUMBER}"
  printf 'router-id %s\n\n' "${BGP_ROUTER_ID}"
  printf 'network inet connected\n\n'
  printf 'nexthop qualify via bgp\n\n'
  printf 'neighbor %s {\n' "${receiver}"
  printf ' remote-as %s\n' "${AS_NUMBER}"
  printf ' announce IPv4 unicast\n'
  printf ' ttl-security yes\n'
  printf '}\n'
} > /etc/bgpd.conf

chmod a-r /etc/bgpd.conf

rcctl enable bgpd
