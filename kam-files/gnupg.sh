#!/bin/sh

set -e

GPG2=$(pkg_info -Q gnupg | grep ^gnupg-2)
pkg_add $GPG2
pkg_add pinentry-gtk2

pkg_add easy-rsa

printf 'export GNUPGHOME=/tmp/.gnupg;mkdir $GNUPGHOME\nchmod 0700 $GNUPGHOME\n' >> /root/.profile
