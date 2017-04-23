#!/bin/sh

set -e

for x in /etc/hostname.* ; do
  printf  '-inet6\n' >> "${x}"
done
