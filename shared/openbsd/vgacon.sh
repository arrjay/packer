#!/bin/sh

case "${PACKER_BUILDER_TYPE}" in
  vmware*)	: > /etc/boot.conf ;;
esac
