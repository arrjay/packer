#!/bin/sh

set -e

pkg_add consul jq

mkdir -p /usr/local/etc

{
  printf '{\n'
  printf '  "bootstrap_expect": 1,\n'
  printf '  "server": true,\n'
  printf '  "ui": false,\n'
  printf '  "enable_syslog": true,\n'
  printf '  "data_dir": "/var/consul"\n'
  printf '}\n'
} > /etc/consul.d/config.json

# we check bgpd here via a script because raw tcp checks cause bgpd to whine
{
  printf 'listener=%s\n' $(dirname "${TRANSIT_IP}")
} > /usr/local/etc/efw-check.conf

{
  printf '{\n'
  printf '  "service": {\n'
  printf '    "name": "bgpd",\n'
  printf '    "tags": [ "efw" ],\n'
  printf '    "port": 179,\n'
  printf '    "check": {\n'
  printf '      "script": "/usr/local/libexec/consul-checks/efw-bgpd.sh",\n'
  printf '      "interval": "60s"\n'
  printf '    }\n'
  printf '  }\n'
  printf '}\n'
  printf '\n'
} > /etc/consul.d/bgpd.json

for j in /etc/consul.d/*.json ; do
  jq . < ${j} > /dev/null
done

mkdir -p /usr/local/libexec/consul-checks
cp /tmp/efw-bgpd.sh /usr/local/libexec/consul-checks
chmod 0755 /usr/local/libexec/consul-checks/*
rm -f /tmp/efw-bgpd.sh

rcctl enable consul
rcctl set consul flags "-config-dir=/etc/consul.d -bind=$(dirname ${TRANSIT_IP})"
