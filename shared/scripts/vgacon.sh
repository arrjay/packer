#!/bin/sh

sys=$(uname -s)
case "${sys}" in
  OpenBSD)
    case "${PACKER_BUILDER_TYPE}" in
      vmware*)	: > /etc/boot.conf ;;
    esac
    ;;
esac
