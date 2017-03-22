#!/bin/sh

set -e

# configure pkg mirror
echo "installpath = $MIRROR" >> /etc/pkg.conf
