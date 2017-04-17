#!/bin/bash

echo "configuring environment"
export ATLAS_BUILD_GITHUB_COMMIT_SHA=$(git rev-parse HEAD)
export ATLAS_BUILD_GITHUB_TAG=$(git describe --exact-match HEAD 2> /dev/null)
export ATLAS_BUILD_SLUG="arrjay/infra"

uname_s=$(uname -s)

case "${uname_s}" in
  Darwin)
    export BUILD_VMWARE_HEADLESS=false
    ;;
  *)
    export BUILD_VMWARE_HEADLESS=true
    ;;
esac
export PACKER_ESX_USER=root

echo "dumping environment"
env

packer version
packer build wcs.json
