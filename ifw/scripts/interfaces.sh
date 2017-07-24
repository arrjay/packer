#!/bin/sh

set -e

[ ! -z "${NETMGMT_IP}" ]
[ ! -z "${ST_USER_IP}" ]
[ ! -z "${DMZ_IP}" ]
[ ! -z "${VIRTHOST_IP}" ]
[ ! -z "${RES_USER_IP}" ]
[ ! -z "${NMS1_INTERNAL_IP}" ]

nms1_relay=$(dirname "${NMS1_INTERNAL_IP}")

case "${PACKER_BUILDER_TYPE}" in
  qemu)		ifbase=vio ;;
  vmware*)	ifbase=vmx ;;
  *)		false ;;
esac

{
  printf 'request option-84;\n'
} >> /etc/dhclient.conf

{
  printf 'inet %s\n' "${DMZ_IP}"
  printf '-inet6\n'
  printf 'group dmz\n'
} > /etc/hostname.${ifbase}2

{
  printf 'inet %s\n' "${VIRTHOST_IP}"
  printf '-inet6\n'
  printf 'group virthosts\n'
} > /etc/hostname.${ifbase}3

cp /etc/rc.d/dhcrelay /etc/rc.d/dhcrelay_virthosts

rcctl enable dhcrelay_virthosts
rcctl set dhcrelay_virthosts flags "-i ${ifbase}3 ${nms1_relay}"

{
  printf 'inet %s\n' "${NETMGMT_IP}"
  printf '-inet6\n'
  printf 'group netmgmt\n'
} > /etc/hostname.${ifbase}4

cp /etc/rc.d/dhcrelay /etc/rc.d/dhcrelay_netmgmt

rcctl enable dhcrelay_netmgmt
rcctl set dhcrelay_netmgmt flags "-i ${ifbase}4 ${nms1_relay}"

{
  printf 'inet %s\n' "${ST_USER_IP}"
  printf '-inet6\n'
  printf 'group standard\n'
} > /etc/hostname.${ifbase}5

cp /etc/rc.d/dhcrelay /etc/rc.d/dhcrelay_stduser

rcctl enable dhcrelay_stduser
rcctl set dhcrelay_stduser flags "-i ${ifbase}5 ${nms1_relay}"

{
  printf 'inet %s\n' "${RES_USER_IP}"
  printf '-inet6\n'
  printf 'group restricted\n'
} > /etc/hostname.${ifbase}6

cp /etc/rc.d/dhcrelay /etc/rc.d/dhcrelay_resuser

rcctl enable dhcrelay_resuser
rcctl set dhcrelay_resuser flags "-i ${ifbase}6 ${nms1_relay}"

