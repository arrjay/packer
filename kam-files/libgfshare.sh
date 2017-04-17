#!/bin/sh

set -e

mkdir -p /usr/local/src
mkdir -p /usr/local/dist
ftp -o /usr/local/dist/libgfshare-2.0.0.tar.gz ${GFSHARE_MIRROR}/files/libgfshare/libgfshare-2.0.0.tar.gz
sha512=$(sha512 /usr/local/dist/libgfshare-2.0.0.tar.gz | cut -d= -f2)
set +e
if [ "${sha512}" != " ead678e3f791c8eb2179e4eacfbad1552bf62be29b7758b3f50e40fdac1efc63f713a0bb03b0e70e8b0fe8c72bf920fb6a44baf6064c74a8bd31194e30dae525" ] ; then
  echo "bad sum for libgfshare-2.0.0.tar.gz, got ${sha512}" 1>&2
  exit 1
fi
set -e

tar xzf /usr/local/dist/libgfshare-2.0.0.tar.gz -C /usr/local/src
cd /usr/local/src/libgfshare-2.0.0
./configure
make
make install
