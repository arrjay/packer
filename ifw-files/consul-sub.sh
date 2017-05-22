#!/bin/sh

set -e

case "${PACKER_BUILDER_TYPE}" in
  qemu)         ifname=vio0 ;;
  vmware*)      ifname=vmx0 ;;
  *)            false ;;
esac

pkg_add consul jq entr

mkdir -p /usr/local/{etc,libexec}

cp /tmp/consul-server.awk /usr/local/libexec
cp /tmp/consul.rc /etc/rc.d/consul

sed -i -e 's@INTERFACE@'${ifname}'@' /etc/rc.d/consul

rcctl enable consul
