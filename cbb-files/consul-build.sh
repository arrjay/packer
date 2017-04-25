#!/bin/sh

set -e

pkg_add go gmake

mkdir -p /usr/local/src
mkdir -p /usr/local/dist
ftp -v -o /usr/local/dist/consul-v0.8.1.tar.gz https://github.com/hashicorp/consul/archive/v0.8.1.tar.gz
sha512=$(sha512 /usr/local/dist/consul-v0.8.1.tar.gz | cut -d= -f2)
set +e
if [ "${sha512}" != " 484fb75f712c29571be5e7fb2f60cd70c8314392771e84756103571d809bb47212aa8572c7276b5e8db933ce48dc50662af89902ba997666fe49de52c8fa0497" ] ; then
  echo "bad sum for consul-v0.8.1.tar.gz, got ${sha512}" 1>&2
  exit 1
fi
set -e
tar xzf /usr/local/dist/consul-v0.8.1.tar.gz -C /usr/local/src
cd /usr/local/src/consul-0.8.1
gmake
false
