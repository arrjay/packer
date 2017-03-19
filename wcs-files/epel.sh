#!/bin/bash

set -e
yum -y install epel-release

set +e
if [ -z "${MIRROR}" ] ; then
  set -e
  echo  "MIRROR not set, not rewiring EPEL repo"
else
  set -e
  printf '[epel]\nbaseurl=%s/fedora-epel/$releasever/$basearch/\ngpgcheck=1\n' $MIRROR > /etc/yum.repos.d/epel.repo
fi

rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
