#!/bin/sh

if [ -z "${WCS_TLD}" ] ; then
  echo "WCS_TLD not set, aborting WCS configuration!"
  exit 1
fi

set -eux
set -o pipefail

yum -y install squid

echo "configuring and enabling squid"
mv -f /tmp/squid.conf /etc/squid/squid.conf
chmod 0644 /etc/squid/squid.conf
restorecon /etc/squid/squid.conf
ln -s /usr/lib/systemd/system/squid.service /etc/systemd/system/multi-user.target.wants/squid.service
