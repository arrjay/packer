#!/bin/sh

set -eux

[ ! -z "${NMS1_INTERNAL_IP}" ]
[ ! -z "${WBRIDGE_IP}" ]
[ ! -z "${PLBRIDGE_IP}" ]

nms1_relay=$(dirname "${NMS1_INTERNAL_IP}")

case "${PACKER_BUILDER_TYPE}" in
  qemu)		ifbase=vio ;;
  vmware*)	ifbase=vmx ;;
  *)		false ;;
esac

{
  printf 'inet %s\n' "${PLBRIDGE_IP}"
  printf '-inet6\n'
  printf 'group pln\n'
} > /etc/hostname.${ifbase}2

cp /etc/rc.d/dhcrelay /etc/rc.d/dhcrelay_pln

rcctl enable dhcrelay_pln
rcctl set dhcrelay_pln flags "-i ${ifbase}2 ${nms1_relay}"

{
  printf 'inet %s\n' "${WBRIDGE_IP}"
  printf '-inet6\n'
  printf 'group wifiext\n'
} > /etc/hostname.${ifbase}3

cp /etc/rc.d/dhcrelay /etc/rc.d/dhcrelay_wifiext

rcctl enable dhcrelay_wifiext
rcctl set dhcrelay_wifiext flags "-i ${ifbase}3 ${nms1_relay}"
