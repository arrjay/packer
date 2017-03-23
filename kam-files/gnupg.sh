#!/bin/sh

GPG2=$(pkg_info -Q gnupg | grep ^gnupg-2)
pkg_add $GPG2
pkg_add pinentry-gtk2
