#!/bin/sh

set -e

mkdir -p /usr/local/src
cd /usr/local/src
git clone git://git.gitano.org.uk/libgfshare.git
. /root/.profile
cd libgfshare
./prep-fresh.sh
./configure
make
make install
