#!/bin/sh

set -e

[ ! -z "${AS_NUMBER}" ]
[ ! -z "${TRANSIT_IP}" ]
[ ! -z "${BGP_ROUTER_ID}" ]
[ ! -z "${BGP_MD5_PASS}" ]

pkg_add sipcalc

subnet=$(sipcalc ${TRANSIT_IP}|awk -F'- ' '$0 ~ "Network address" { print $2 }')
cidr=$(basename ${TRANSIT_IP})
listener=$(echo ${TRANSIT_IP}|sed 's@/'${cidr}'@@')

{
  printf 'AS %s\n' "${AS_NUMBER}"
  printf 'router-id %s\n\n' "${BGP_ROUTER_ID}"
  printf 'nexthop qualify via bgp\n\n'
  printf 'listen on %s\n\n' "${listener}"
  printf 'neighbor %s/%s {\n' "${subnet}" "${cidr}"
  printf ' local-address %s\n' "${listener}"
  printf ' announce IPv4 unicast\n'
  printf ' announce default-route\n'
  printf ' tcp md5sig password %s\n' "${BGP_MD5_PASS}"
  printf ' ttl-security yes\n'
  printf '}\n'
} > /etc/bgpd.conf

chmod a-r /etc/bgpd.conf

rcctl enable bgpd
