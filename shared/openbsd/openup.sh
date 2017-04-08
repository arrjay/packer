#!/bin/sh
set -e

# install openup ( https://www.mtier.org/solutions/apps/openup/ )
printf 'OPENUP_URL="http://%s/openup"\n' "${OPENUP_MIRROR}" > /etc/openup.conf
printf 'PKG_PUBKEY_URL="http://%s/mtier-$(uname -r|tr -d '.')-pkg.pub"\n' "${OPENUP_MIRROR}" >> /etc/openup.conf
printf 'PKG_PATH_MAIN="http://%s/pub/OpenBSD/$(uname -r)/packages/$(arch -s)"\n' "${MIRROR}" >> /etc/openup.conf
printf 'PKG_PATH_UPDATE="http://%s/updates/$(uname -r)/$(arch -s)"\n' "${OPENUP_MIRROR}" >> /etc/openup.conf
printf 'VUXML_URL="http://%s/vuxml/$(uname -r | tr -d '.').xml"\n' "${OPENUP_MIRROR}" >> /etc/openup.conf
chmod 0600 /etc/openup.conf

cp /tmp/openup /usr/local/sbin
chmod +x /usr/local/sbin/openup

# do a run now
/usr/local/sbin/openup

# reboot
shutdown -r now
