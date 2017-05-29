#!/bin/sh

set -x

mkdir -p /root/.ssh
printf 'Host *\n StrictHostKeyChecking No\n' > /root/.ssh/config
chmod 400 /root/.ssh/config

cd /usr
cvs -qd anoncvs@anoncvs.ca.openbsd.org:/cvs get -rOPENBSD_6_1 -P ports > /dev/null
ls -l /usr/ports/sysutils
cd /usr/ports/sysutils/consul
pwd
make package
