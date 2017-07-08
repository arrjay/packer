#!/bin/bash

# see if we have a directory, if not make it
if [ ! -d /srv/nginx-cache ] ; then
  mkdir /srv/nginx-cache
fi

if [ -e /sys/fs/selinux/status ] ; then
  topcon=$(stat /srv/nginx-cache --format=%C)
  case "${topcon}" in
    *httpd_sys_rw_content_t*)
      # noop
      ;;
    *)
      semanage fcontext --add -t httpd_sys_rw_content_t '/srv/nginx-cache(/.*)?'
      restorecon -R /srv/nginx-cache
      ;;
  esac
fi


# also DACL permissions should be squid:squid 0750
fsug=$(stat /srv/nginx-cache --format %U:%G)
case "${fsgroup}" in
  nginx:nginx)
    # noop
    ;;
  *)
    chown -R nginx:nginx /srv/nginx-cache
    ;;
esac

fsmode=$(stat /srv/nginx-cache --format '%#03a')
case "${fsmode}" in
  0750)
    : # noop
    ;;
  *)
    find /srv/nginx-cache -type d -exec chmod 0750 {} \;
    find /srv/nginx-cache -type f -exec chmod 0640 {} \;
    ;;
esac
