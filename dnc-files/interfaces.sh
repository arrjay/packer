#!/bin/sh

set -e

case "${PACKER_BUILDER_TYPE}" in
  qemu)		ifname=vio0 ;;
  vmware*)	ifname=vmx0 ;;
  *)		false ;;
esac

{
  printf 'inet %s\n' "${IPADDR}"
  printf '-inet6\n'
} > /etc/hostname.$ifname

gw=$(dirname "${DEFAULTGW}")


printf '%s\n' "${gw}" > /etc/mygate
