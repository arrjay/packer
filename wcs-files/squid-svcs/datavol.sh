#!/bin/bash

# okay. do we have a mountpoint?
if [ ! -d /var/spool/squid ] ; then
  echo "there is no mountpoint for this, aborting" 1>&2
  exit 1
fi

# are we already mounted? silently go away.
grep -q /var/spool/squid /proc/mounts
if [ $? == 0 ] ; then
  exit 0
fi

# do we exist in fstab? if so, try to mount that first. die if we fail.
grep -q /var/spool/squid /etc/fstab
if [ $? == 0 ] ; then
  mount /var/spool/squid
  if [ $? != 0 ] ; then
    echo "tried to mount /var/spool/squid and someone got mad. aborting." 1>&2
    exit 1
  else
    # we mounted a filesystem! stop.
    exit 0
  fi
else
  # do we already have a fslabeled disk? try to use that.
  if [ -e /dev/disk/by-label/squidcache ] ; then
    printf 'LABEL=squidcache /var/spool/squid xfs noauto 0 0\n' >> /etc/fstab
    mount /var/spool/squid
    if [ $? != 0 ] ; then
      echo "tried to mount existing squidcache as /var/spool/squid and someone got mad. aborting." 1>&2
      exit 1
    else
      # we mounted a filesystem! stop.
      exit 0
    fi
  fi
fi

# meander through sysfs to find a disk with no partitions that is r/w.
for d in /sys/class/block/[vsx]d[a-z] ; do
  cdisk=$(basename $d)
  # read-only check - don't stop the loop, but restart it
  read ro < /sys/class/block/${cdisk}/ro
  if [ ${ro} != 0 ] ; then
    continue
  fi
  # partition check - done by checking if wildcard resolves to a existing object
  partitions=0
  for p in /sys/class/block/${cdisk}[0-9]* ; do
    if [ -e ${p} ] ; then
      partitions=1
      break
    fi
  done
  if [ ${partitions} == 0 ] ; then
    disk=${cdisk}
    break
  fi
done

if [ -z "${disk}" ] ; then
  echo "no unpartitioned disks found, aborting" 1>&2
  exit 1
fi

# catch fire past this point
set -e

# partition what we got
parted /dev/${disk} mklabel gpt
parted /dev/${disk} mkpart '' ext1 1m 100%

# wait a touch for udev to settle
sleep 1

# format that as a filesystem
mkfs.xfs -Lsquidcache /dev/${disk}1

# add to fstab now
printf 'LABEL=squidcache /var/spool/squid xfs noauto 0 0\n' >> /etc/fstab

# mount via fstab mechnism plz
mount /var/spool/squid

# selinux fixups - flip set over for testing
set +e
if [ -e /sys/fs/selinux/status ] ; then
  set -e
  topcon=$(stat /var/spool/squid --format=%C)
  case "${topcon}" in
    *squid_cache_t*)
      # noop
      ;;
    *)
      restorecon -R /var/spool/squid
      ;;
  esac
fi
set -e

# also DACL permissions should be squid:squid 0750
fsug=$(stat /var/spool/squid --format %U:%G)
case "${fsgroup}" in
  squid:squid)
    # noop
    ;;
  *)
    chown -R squid:squid /var/spool/squid
    ;;
esac

fsmode=$(stat /var/spool/squid --format %#03a)
case "${fsmode}" in
  0750)
    # noop
    ;;
  *)
    find /var/spool/squid -type d -exec chmod 0750 {} \;
    find /var/spool/squid -type f -exec chmod 0640 {} \;
    ;;
esac
