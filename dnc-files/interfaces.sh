#!/bin/sh

set -e

case "${PACKER_BUILDER_TYPE}" in
  qemu)		ifname=vio0 ;;
  vmware*)	ifname=vmx0 ;;
  *)		false ;;
esac

gw=$(dirname "${DEFAULTGW}")

{
  printf 'inet %s\n' "${IPADDR}"
  printf '-inet6\n'
  printf '!route add default %s\n' "${gw}"
} > /etc/hostname.$ifname
