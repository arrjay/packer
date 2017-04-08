#!/bin/sh

set -e

# configure pkg mirror
echo "installpath = http://$MIRROR/pub/OpenBSD/$(uname -r)/packages/$(machine -a)" > /etc/pkg.conf
echo "http://$MIRROR/pub/OpenBSD/" > /etc/installurl
