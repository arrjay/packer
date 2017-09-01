#!/bin/sh

set -e

# configure chrony to advertise time services
sed -i -e 's/^server.*//g' /etc/chrony.conf # first, remove static servers in favor of vmm

# bind to all interfaces, allow all ips (the firewall will restrict where this works)
{
  printf 'bindaddress 0.0.0.0\n'
  printf 'allow\n'
} >> /etc/chrony.conf

# and firewalld.
firewall-cmd --permanent --zone public --add-service ntp
