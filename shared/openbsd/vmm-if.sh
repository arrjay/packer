#!/bin/sh

set -e

case "${PACKER_BUILDER_TYPE}" in
  qemu)		ifname=vio1 ;;
  vmware*)	ifname=vmx1 ;;
  *)		false ;;
esac

{
  printf 'dhcp\n'
  printf '-inet6\n'
  printf 'group vmm\n'
} > /etc/hostname.$ifname
