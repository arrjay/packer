#!/bin/sh

set -e

[ -f /tmp/update-dns ]

keytype=$(echo ${NMS1_DNS_KEY_TYPE} | tr [A-Z] [a-z] | sed s/_/-/)
keyname="nms1."

{
  printf 'KEY="%s:%s:%s"\n' "${keytype}" "${keyname}" "${NMS1_DNS_KEY_DATA}"
  printf 'NS=127.0.0.1\n'
} > /usr/local/etc/update-dns.conf

# https://bugzilla.redhat.com/show_bug.cgi?id=1301854
install -D -m 0755 /tmp/update-dns /etc/dhcp/scripts/update-dns && rm /tmp/update-dns
restorecon -R /etc/dhcp/scripts

# https://bugzilla.redhat.com/show_bug.cgi?id=1349044
chgrp dhcpd /etc/dhcp
