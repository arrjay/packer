#!/bin/sh

set -e

# configure pkg mirror
echo "installpath = $MIRROR/pub/OpenBSD/$(uname -r)/packages/$(machine -a)" > /etc/pkg.conf
echo "$MIRROR/pub/OpenBSD/" > /etc/installurl
