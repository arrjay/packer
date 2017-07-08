#!/bin/sh

if [ -z "${WCS_TLD}" ] ; then
  echo "WCS_TLD not set, aborting WCS configuration!"
  exit 1
fi

set -eux
set -o pipefail

yum -y install squid policycoreutils-python

echo "configuring and enabling squid"
mv -f /tmp/squid.conf /etc/squid/squid.conf
chmod 0644 /etc/squid/squid.conf
restorecon /etc/squid/squid.conf
cp /tmp/squiddir.sh /usr/local/sbin
chmod 0750 /usr/local/sbin/squiddir.sh
cp /tmp/squiddir.unit /etc/systemd/system/squiddir.service
mkdir -p /etc/systemd/system/squid.service.requires
ln -s /etc/systemd/system/squiddir.service /etc/systemd/system/squid.service.requires/squiddir.service
ln -s /usr/lib/systemd/system/squid.service /etc/systemd/system/multi-user.target.wants/squid.service
