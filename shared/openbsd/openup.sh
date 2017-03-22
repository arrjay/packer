#!/bin/sh
set -e

# install openup ( https://www.mtier.org/solutions/apps/openup/ )
cp /tmp/openup /usr/local/sbin
chmod +x /usr/local/sbin/openup

# do a run now
/usr/local/sbin/openup

# reboot
shutdown -r now
