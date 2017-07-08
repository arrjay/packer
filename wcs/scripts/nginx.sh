#!/bin/bash

set -eux
set -o pipefail

yum -y install nginx policycoreutils-python

echo "configuring and enabling nginx"
# terrible hack to encode upstream status in the main log
cp /tmp/nginxdir.sh /usr/local/sbin
chmod 0750 /usr/local/sbin/nginxdir.sh
cp /tmp/nginxdir.unit /etc/systemd/system/nginxdir.service
sed -i -e 's@$status@$status/$upstream_cache_status@' /etc/nginx/nginx.conf
printf 'proxy_cache_path /srv/nginx-cache levels=1:2 keys_zone=wcs_cache:10m max_size=20g inactive=14d use_temp_path=off;\n' > /etc/nginx/conf.d/proxypath.conf

mkdir -p /etc/systemd/system/nginx.service.requires
ln -s /etc/systemd/system/nginxdir.service /etc/systemd/system/nginx.service.requires/nginxdir.service
ln -s /usr/lib/systemd/system/nginx.service /etc/systemd/system/multi-user.target.wants/nginx.service
