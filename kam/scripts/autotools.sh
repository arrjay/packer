#!/bin/sh

set -e

ACVER=$(pkg_info -Q autoconf | grep -E 'autoconf-[0-9]' | tail -n1 | cut -d- -f2)
pkg_add autoconf-$ACVER
AUTOCONF_VERSION=$(echo $ACVER | cut -dp -f1)
printf '\nexport AUTOCONF_VERSION=%s\n' $AUTOCONF_VERSION >> /root/.profile
AMVER=$(pkg_info -Q automake | cut -d- -f2 | sort -V | tail -n1)
AUTOMAKE_VERSION=$(echo $AMVER | cut -dp -f1)
printf '\nexport AUTOMAKE_VERSION=%s\n' $AUTOMAKE_VERSION >> /root/.profile
pkg_add automake-$AMVER
pkg_add libtool
