#!/bin/sh
set -e

# install openup ( https://www.mtier.org/solutions/apps/openup/ )
ftp -o /usr/local/sbin/openup http://$PACKER_HTTP_ADDR/redist/openup
chmod +x /usr/local/sbin/openup

# do a run now
/usr/local/sbin/openup

# reboot
shutdown -r now
