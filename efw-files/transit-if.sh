#!/bin/sh

set -e

case "${PACKER_BUILDER_TYPE}" in
  qemu)		ifname=vio1 ;;
  vmware*)	ifname=vmx1 ;;
  *)		false ;;
esac

{
  printf 'inet %s\n' "${TRANSIT_IP}"
  printf '-inet6\n'
  printf 'group transit\n'
} > /etc/hostname.$ifname
