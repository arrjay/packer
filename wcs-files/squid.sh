#!/bin/sh

if [ -z "${WCS_TLD}" ] ; then
  echo "WCS_TLD not set, aborting WCS configuration!"
  exit 1
fi

set -e

yum -y install squid
