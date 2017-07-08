#!/bin/bash

set -e
yum -y install epel-release

set +e
if [ -z "${EPEL_MIRROR}" ] ; then
  set -e
  echo  "EPEL_MIRROR not set, not rewiring EPEL repo"
else
  set -e
  printf '[epel]\nbaseurl=%s/$releasever/$basearch/\ngpgcheck=1\n' "${EPEL_MIRROR}" > /etc/yum.repos.d/epel.repo
fi

rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
