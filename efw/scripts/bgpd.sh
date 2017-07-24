#!/bin/sh

set -e

[ ! -z "${AS_NUMBER}" ]
[ ! -z "${TRANSIT_IP}" ]
[ ! -z "${BGP_ROUTER_ID}" ]

[ ! -z "${VMM_RANGE}" ]

pkg_add sipcalc

subnet=$(sipcalc ${TRANSIT_IP}|awk -F'- ' '$0 ~ "Network address" { print $2 }')
cidr=$(basename ${TRANSIT_IP})
listener=$(echo ${TRANSIT_IP}|sed 's@/'${cidr}'@@')

{
  printf 'AS %s\n' "${AS_NUMBER}"
  printf 'router-id %s\n\n' "${BGP_ROUTER_ID}"
  printf 'nexthop qualify via bgp\n\n'
  printf 'deny from any prefix { %s }\n\n' "${VMM_RANGE}"
  printf 'listen on %s\n\n' "${listener}"
  printf 'neighbor %s/%s {\n' "${subnet}" "${cidr}"
  printf ' remote-as %s\n' "${AS_NUMBER}"
  printf ' announce IPv4 unicast\n'
  printf ' announce default-route\n'
  printf ' ttl-security yes\n'
  printf '}\n'
} > /etc/bgpd.conf

chmod a-r /etc/bgpd.conf

bgpd -dn

rcctl enable bgpd
