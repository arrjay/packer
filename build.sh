#!/bin/bash

echo "configuring environment"
export ATLAS_BUILD_GITHUB_COMMIT_SHA=$(git rev-parse HEAD)
export ATLAS_BUILD_GITHUB_TAG=$(git describe --exact-match HEAD 2> /dev/null)
export ATLAS_BUILD_SLUG="arrjay/infra"
export BUILD_TIMESTAMP=$(date +%s)
export PASSWORD_STORE_DIR=$(pwd)/vault

for x in ${PASSWORD_STORE_DIR}/*.gpg ; do
  name=$(basename "${x}" .gpg)
  declare -x ${name}=$(pass ls ${name})
done

if [ -z "${MIRRORS_KERNEL_ORG}" ] ; then
  echo "setting MIRRORS_KERNEL_ORG"
  export MIRRORS_KERNEL_ORG="http://mko.wcs.bbxn.us"
fi

if [ -z "${MIRRORS_OPENBSD}" ] ; then
  echo "settings MIRRORS_OPENBSD"
  export MIRRORS_OPENBSD="http://sonic-mirrors.wcs.bbxn.us"
fi

if [ -z "${MIRRORS_GNUPG}" ] ; then
  echo "settings MIRRORS_GNUPG"
  export MIRRORS_GNUPG="http://gnupg.wcs.bbxn.us"
fi

if [ -z "${MIRRORS_LIBGFSHARE}" ] ; then
  echo "settings MIRRORS_LIBGFSHARE"
  export MIRRORS_LIBGFSHARE="http://dscurf.wcs.bbxn.us"
fi

if [ -z "${MIRRORS_YKDEV}" ] ; then
  echo "settings MIRRORS_YKDEV"
  export MIRRORS_YKDEV="http://ykdev.wcs.bbxn.us"
fi

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
export BUILD_QEMU_HEADLESS=true
export PACKER_VNC_NOPASSWORD=true

echo "dumping environment"
env

packer version
set -x
packer build \
\
  -var "build_slug=arrjay/infra" \
  -var "build_sha=$(git rev-parse HEAD)" \
  -var "build_tag=$(git describe --exact-match HEAD 2> /dev/null)" \
  -var "build_ts=$BUILD_TIMESTAMP" \
\
  -var "packer_esx_remote_type=$PACKER_ESX_RTYPE" \
  -var "packer_esx_remote_host=$PACKER_ESX_HOST" \
  -var "packer_esx_remote_user=$PACKER_ESX_USER" \
  -var "packer_esx_remote_pass=$PACKER_ESX_PASS" \
  -var "packer_esx_remote_datastore=$PACKER_ESX_DATASTORE" \
  -var "packer_esx_remote_network=$PACKER_ESX_PORTGROUP" \
  -var "packer_vmware_headless=$BUILD_VMWARE_HEADLESS" \
  -var "packer_vmware_keep_registered=$PACKER_VMWARE_KEEP" \
  -var "packer_vmware_vnc_passwordless=$PACKER_VNC_NOPASSWORD" \
\
  -var "packer_qemu_headless=$BUILD_QEMU_HEADLESS" \
\
  -var "mirrors_kernel_org=$MIRRORS_KERNEL_ORG" \
  -var "mirrors_openbsd=$MIRRORS_OPENBSD" \
  -var "mirrors_gnupg=$MIRRORS_GNUPG" \
  -var "mirrors_libgfshare=$MIRRORS_LIBGFSHARE" \
  -var "mirrors_ykdev=$MIRRORS_YKDEV" \
  -var "mirrors_openup=$MIRRORS_OPENUP" \
\
  -var-file packer/vars2.json packer/wcs.json
