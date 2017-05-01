#!/bin/sh

set -x

# bootstrap will exit 1
unbound-anchor

set -e

mv /tmp/unbound.conf /var/unbound/etc/unbound.conf
chmod 0644 /var/unbound/etc/unbound.conf
chown root /var/unbound/etc/unbound.conf
chgrp wheel /var/unbound/etc/unbound.conf

printf 'nameserver %s\nlookup file bind\n' "127.0.0.1" > /etc/resolv.conf

rcctl enable unbound
