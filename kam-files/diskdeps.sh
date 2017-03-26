#!/bin/sh

set -e

pkg_add e2fsprogs
pkg_add rsync--
cp /tmp/save.sh /root
chmod +x /root/save.sh
