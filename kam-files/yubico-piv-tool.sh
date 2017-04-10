#!/bin/sh

set -e

mkdir -p /usr/local/src
mkdir -p /usr/local/dist
ftp -o /usr/local/dist/yubico-piv-tool-1.4.2.tar.gz https://developers.yubico.com/yubico-piv-tool/Releases/yubico-piv-tool-1.4.2.tar.gz
sha512=$(sha512 /usr/local/dist/yubico-piv-tool-1.4.2.tar.gz | cut -d= -f2)
set +e
if [ "${sha512}" != " 9726c6cf3a55435127748590dd879cfe0e066a451f1f13f010c12fad012b45bf50c2c4745a06ea500b32839c48ab56c761960b85b614326fedc323b42c3aeb7c" ] ; then
  echo "bad sum for yubico-piv-tool-1.4.2.tar.gz, got ${sha512}" 1>&2
  exit 1
fi
set -e
tar xzf /usr/local/dist/yubico-piv-tool-1.4.2.tar.gz -C /usr/local/src
cd /usr/local/src/yubico-piv-tool-1.4.2
./configure
make
make install