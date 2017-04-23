#!/bin/sh

set -e

{
  printf 'inet %s\n' "${TRANSIT_IP}"
  printf '-inet6\n'
  printf 'group transit\n'
} > /etc/hostname.vio1
