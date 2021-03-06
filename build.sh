#!/bin/bash

echo "configuring initial environment"
export ATLAS_BUILD_GITHUB_COMMIT_SHA=$(git rev-parse HEAD)
export ATLAS_BUILD_GITHUB_TAG=$(git describe --exact-match HEAD 2> /dev/null)
export ATLAS_BUILD_SLUG="arrjay/infra"
export BUILD_TIMESTAMP=$(date +%s)
export PASSWORD_STORE_DIR=$(pwd)/vault
export PACKER_ENV_DIR=$(pwd)/packer_env
type qemu-system-x86_64 > /dev/null 2>&1
if [ "${?}" -ne 0 ] ; then
  if [ -f /usr/libexec/qemu-kvm ] ; then
    PACKER_BUILD_FLAGS+=" -var qemu_binary=/usr/libexec/qemu-kvm"
  fi
else
  PACKER_BUILD_FLAGS+=" -var qemu_binary=qemu-system-x86_64"
fi

case "${uname_s}" in
  Darwin)
    export BUILD_VMWARE_HEADLESS=false
    ;;
  *)
    export BUILD_VMWARE_HEADLESS=true
    ;;
esac

# this sets environment variables from the password store
echo "loading vault..."
for x in ${PASSWORD_STORE_DIR}/*.gpg ; do
  name=$(basename "${x}" .gpg)
  declare -x ${name}="$(pass ls ${name})"
done

# this starts setting packer variables
PACKER_BUILD_FLAGS+=" -var build_sha=$(git rev-parse HEAD)"
PACKER_BUILD_FLAGS+=" -var build_tag=$(git describe --exact-match HEAD 2> /dev/null)"
PACKER_BUILD_FLAGS+=" -var build_ts=${BUILD_TIMESTAMP}"

# this continues to set packer variables - note the ${!} construct expands env
echo "loading packer env vars..."
for x in ${PACKER_ENV_DIR}/* ; do
  pkname=$(basename "${x}")
  read pkdata < "${x}"
  if [ "${pkdata:0:1}" == '$' ] ; then
    pkdata=${pkdata:1:${#pkdata}}
    PACKER_BUILD_FLAGS+=" -var ${pkname}=${!pkdata}"
  else
    PACKER_BUILD_FLAGS+=" -var ${pkname}=${pkdata}"
  fi
done

uname_s=$(uname -s)

packer version
packer build \
  $PACKER_BUILD_FLAGS \
  -var-file packer/vars2.json "${1}"
