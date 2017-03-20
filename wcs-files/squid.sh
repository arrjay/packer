#!/bin/sh

if [ -z "${WCS_TLD}" ] ; then
  echo "WCS_TLD not set, aborting WCS configuration!"
  exit 1
fi

set -e

yum -y install squid

echo "creating squid requires overrides"
mkdir -p /etc/systemd/system/squid.service.requires

echo "installing data volume service"
mv /tmp/datavol.sh /usr/local/sbin
chmod 0750 /usr/local/sbin/datavol.sh
cp /tmp/datavol.unit /etc/systemd/system/squid-datavol.service
chmod 0644 /etc/systemd/system/squid-datavol.service
ln -s /etc/systemd/system/squid-datavol.service /etc/systemd/system/squid.service.requires/squid-datavol.service
