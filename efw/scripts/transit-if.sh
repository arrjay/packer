#!/bin/sh

set -e

case "${PACKER_BUILDER_TYPE}" in
  qemu)		ifname=vio2 ;;
  vmware*)	ifname=vmx2 ;;
  *)		false ;;
esac

{
  printf 'inet %s\n' "${TRANSIT_IP}"
  printf '-inet6\n'
  printf 'group transit\n'
} > /etc/hostname.$ifname
