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

echo "configuring and enabling squid"
mv -f /tmp/squid.conf /etc/squid/squid.conf
chmod 0644 /etc/squid/squid.conf
restorecon /etc/squid/squid.conf
ln -s /usr/lib/systemd/system/squid.service /etc/systemd/system/multi-user.target.wants/squid.service

echo "configuring firewalld"
firewall-cmd --permanent --zone=public --add-service=http

echo "updating /etc/hosts"
echo "127.0.0.1 mko.wcs.bbxn.us" >> /etc/hosts
echo "127.0.0.1 mtier.wcs.bbxn.us" >> /etc/hosts
echo "127.0.0.1 sonic-mirrors.wcs.bbxn.us" >> /etc/hosts
echo "127.0.0.1 gnupg.wcs.bbxn.us" >> /etc/hosts
echo "127.0.0.1 dscurf.wcs.bbxn.us" >> /etc/hosts
