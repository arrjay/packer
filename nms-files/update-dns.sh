#!/bin/sh

set -e

[ -f /tmp/update-dns ]

keytype=$(echo ${NMS1_DNS_KEY_TYPE} | tr [A-Z] [a-z] | sed s/_/-/)
keyname="nms1."

{
  printf 'KEY=%s:%s:%s:%s\n' "${keytype}" "${keyname}" "${NMS1_DNS_KEY_DATA}"
  printf 'NS=127.0.0.1\n'
} > /usr/local/etc/update-dns.conf

mv /tmp/update-dns /usr/local/sbin/update-dns && chmod 0755 /usr/local/sbin/update-dns
