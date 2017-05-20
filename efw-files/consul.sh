#!/bin/sh

set -e

pkg_add consul jq

{
  printf '{\n'
  printf '  "bootstrap_expect": 1,\n'
  printf '  "server": true,\n'
  printf '  "ui": false,\n'
  printf '  "enable_syslog": true,\n'
  printf '  "data_dir": "/var/consul"\n'
  printf '}\n'
} > /etc/consul.d/config.json

jq . < /etc/consul.d/config.json > /dev/null

rcctl enable consul
rcctl set consul flags "-config-dir=/etc/consul.d -bind=$(dirname ${TRANSIT_IP})"
