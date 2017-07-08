#!/bin/bash

# see if we have a directory, if not make it
if [ ! -d /srv/squid-cache ] ; then
  mkdir /srv/squid-cache
fi

if [ -e /sys/fs/selinux/status ] ; then
  topcon=$(stat /srv/squid-cache --format=%C)
  case "${topcon}" in
    *squid_cache_t*)
      # noop
      ;;
    *)
      semanage fcontext --add -t squid_cache_t '/srv/squid-cache(/.*)?'
      restorecon -R /srv/squid-cache
      ;;
  esac
fi


# also DACL permissions should be squid:squid 0750
fsug=$(stat /srv/squid-cache --format %U:%G)
case "${fsgroup}" in
  squid:squid)
    # noop
    ;;
  *)
    chown -R squid:squid /srv/squid-cache
    ;;
esac

fsmode=$(stat /srv/squid-cache --format '%#03a')
case "${fsmode}" in
  0750)
    : # noop
    ;;
  *)
    find /srv/squid-cache -type d -exec chmod 0750 {} \;
    find /srv/squid-cache -type f -exec chmod 0640 {} \;
    ;;
esac
