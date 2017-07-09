#!/bin/sh

which syspatch ; rc=$?

if [ $rc -eq 0 ] ; then
  set -e
  syspatch
  reboot
  exit 0
fi
