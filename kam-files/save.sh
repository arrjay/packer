#!/bin/sh

OIFS=IFS
IFS=,
mydev=''

for disk in $(sysctl -n hw.disknames) ; do
  topdev=${disk%%:*}
  for dev in /dev/$topdev? ; do
    label=$(e2label $dev 2> /dev/null)
    if [[ $label == "black" ]] ; then
      mydev=$dev
      break
    fi
  done
  if [ ! -z "${mydev}" ] ; then
    break
  fi
done

IFS=$OIFS

set -e

mount $dev /mnt
