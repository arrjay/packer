#!/bin/sh

set -e

[ ! -z "${AS_NUMBER}" ]
[ ! -z "${INTERNAL_EFW_IP}" ]
[ ! -z "${BGP_ROUTER_ID}" ]

[ ! -z "${DMZ_IP}" ]
[ ! -z "${VIRTHOST_IP}" ]
[ ! -z "${NETMGMT_IP}" ]
[ ! -z "${ST_USER_IP}" ]
[ ! -z "${RES_USER_IP}" ]

[ ! -z "${VMM_RANGE}" ]

pkg_add sipcalc

rcv_cidr=$(basename ${INTERNAL_EFW_IP})
receiver=$(echo ${INTERNAL_EFW_IP}|sed 's@/'${rcv_cidr}'@@')

dmz_cidr=$(basename ${DMZ_IP})
dmz_net=$(sipcalc ${DMZ_IP}|awk -F'- ' '$0 ~ "Network address" { print $2 }')

virthost_cidr=$(basename ${VIRTHOST_IP})
virthost_net=$(sipcalc ${VIRTHOST_IP}|awk -F'- ' '$0 ~ "Network address" { print $2 }')

netmgmt_cidr=$(basename ${NETMGMT_IP})
netmgmt_net=$(sipcalc ${NETMGMT_IP}|awk -F'- ' '$0 ~ "Network address" { print $2 }')

st_user_cidr=$(basename ${ST_USER_IP})
st_user_net=$(sipcalc ${ST_USER_IP}|awk -F'- ' '$0 ~ "Network address" { print $2 }')

res_user_cidr=$(basename ${RES_USER_IP})
res_user_net=$(sipcalc ${RES_USER_IP}|awk -F'- ' '$0 ~ "Network address" { print $2 }')

{
  printf 'AS %s\n' "${AS_NUMBER}"
  printf 'router-id %s\n\n' "${BGP_ROUTER_ID}"
  printf 'network %s/%s\n' "${dmz_net}" "${dmz_cidr}"
  printf 'network %s/%s\n' "${virthost_net}" "${virthost_cidr}"
  printf 'network %s/%s\n' "${netmgmt_net}" "${netmgmt_cidr}"
  printf 'network %s/%s\n' "${st_user_net}" "${st_user_cidr}"
  printf 'network %s/%s\n' "${res_user_net}" "${res_user_cidr}"
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
