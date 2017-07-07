#!/bin/bash

set -eux
set -o pipefail

cp /tmp/varnish5.repo /etc/yum.repos.d
cp /tmp/RPM-GPG-varnish5 /etc/pki/rpm-gpg

yum -y install varnish
