#!/bin/bash

set -eux
set -o pipefail

echo "creating squid,nginx requires overrides"
mkdir -p /etc/systemd/system/squid.service.requires
mkdir -p /etc/systemd/system/nginx.service.requires

echo "installing data volume service"
mv /tmp/datavol.sh /usr/local/sbin
chmod 0750 /usr/local/sbin/datavol.sh
cp /tmp/datavol.unit /etc/systemd/system/datavol.service
chmod 0644 /etc/systemd/system/datavol.service
#ln -s /etc/systemd/system/datavol.service /etc/systemd/system/squid.service.requires/squid-datavol.service
