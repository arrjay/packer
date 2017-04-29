#!/bin/sh

BUILD_STR=""
HUMANTIME=$(date --date=@$BUILD_TS|sed 's/:/./g')

if [ -z "$SYSTEM_TAG" ] ; then
  echo "SYSTEM_TAG not in environment, aborting" 1>&2
fi

if [ -z "$BUILD_SHA" ] ; then
  echo "BUILD_SHA not in environment, aborting" 1>&2
  exit 1
else
  BUILD_STR="Build $BUILD_SHA"
  echo "Building $SYSTEM_TAG commit $BUILD_SHA"
  echo "(Timestamp $HUMANTIME)"
fi

set -e

echo "${SYSTEM_TAG} ${BUILD_STR}" >> /etc/issue
echo "Built ${HUMANTIME}" >> /etc/issue
echo "" >> /etc/issue