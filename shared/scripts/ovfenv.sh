#!/bin/sh

set -e

sys=$(uname -s)
case "${sys}" in
  OpenBSD)
    pkg_add libxslt
    ;;
esac
