#!/bin/sh

set -e

pkg_add go gmake git bash

go get github.com/mitchellh/gox

mkdir -p /usr/local/src
cd /usr/local/src
git clone https://github.com/hashicorp/consul
cd consul
git checkout v0.8.1
patch -p1 < /tmp/consul-build.patch
gmake
false
