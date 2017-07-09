#!/bin/bash

set -eux
set -o pipefail

yum -y install nginx policycoreutils-python

echo "configuring and enabling nginx"
# terrible hack to encode upstream status in the main log
cp /tmp/nginxdir.sh /usr/local/sbin
chmod 0750 /usr/local/sbin/nginxdir.sh
cp /tmp/nginxdir.unit /etc/systemd/system/nginxdir.service
cp /tmp/nginx.conf /etc/nginx/nginx.conf
printf 'proxy_cache_path /srv/nginx-cache levels=1:2 keys_zone=ngx_cache:10m max_size=20g inactive=14d use_temp_path=off;\n' > /etc/nginx/conf.d/proxypath.conf
printf 'upstream wcs.bbxn.us {\nserver wcs.bbxn.us:80;\n}\n' > /etc/nginx/conf.d/upstream-wcs.bbxn.us.conf
{
  printf 'slice 5m;\nproxy_cache_key $uri$is_args$args$slice_range;\nproxy_set_header Range $slice_range;\nproxy_cache_revalidate on;\n'
  printf 'proxy_cache_use_stale error timeout updating;\nadd_header X-Cache-Status $upstream_cache_status;\nproxy_intercept_errors on;\n'
  printf 'proxy_cache ngx_cache;\nproxy_cache_lock on;\nproxy_cache_valid 200 206 8h;\nproxy_cache_valid any 5m;\n'
} > /etc/nginx/default.d/00-proxy-cache.conf
{
  printf 'location ~*\.(deb|exe|fs|img|iso|pdf|rpm|tar\.(bz2|gz|xz)|tgz|zip)$ {\nproxy_cache_valid 200 206 7d;\n}\n'
  printf 'location ~*vmlinuz {\nproxy_cache_valid 200 206 7d;\n}\n'
} > /etc/nginx/default.d/50-proxy-ext.conf

printf 'location ^~ / {\nproxy_pass http://wcs.bbxn.us/;\n}\n' > /etc/nginx/default.d/ALL.conf

nginx -t

mkdir -p /etc/systemd/system/nginx.service.requires
ln -s /etc/systemd/system/nginxdir.service /etc/systemd/system/nginx.service.requires/nginxdir.service
ln -s /usr/lib/systemd/system/nginx.service /etc/systemd/system/multi-user.target.wants/nginx.service
