#!/bin/sh

BUILD_STR=""
HUMANTIME=$(date -r $BUILD_TS|sed 's/:/./g')

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

# replace im= attribute in getty with build info
sed -i.dist -e 's/im=.*:/im=\\r\\n\%s\/\%m '"$SYSTEM_TAG"' '"$BUILD_STR"'\\r\\nBuilt '"$HUMANTIME"' (\\%t)\\r\\n\\r\\n:/' /etc/gettytab
