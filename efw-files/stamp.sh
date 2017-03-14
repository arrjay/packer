#!/bin/sh

BUILD_STR=""

if [ -z "$BUILD_SHA" ] ; then
  echo "BUILD_SHA not in environment, aborting" 1>&2
  exit 1
else
  BUILD_STR="Build $BUILD_SHA"
  echo "Building EFW commit $BUILD_SHA"
fi

# replace im= attribute in getty with build info
sed -i.dist -e 's/im=.*:/im=\\r\\n\%s\/\%m EFW '"$BUILD_STR"' (\\%t)\\r\\n\\r\\n:/' /etc/gettytab
