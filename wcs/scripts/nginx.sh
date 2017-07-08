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
printf 'upstream mirrors.kernel.org {\nserver mirrors.kernel.org:443;\n}\n' > /etc/nginx/conf.d/upstream-mirrors.kernel.org.conf
{
  printf 'proxy_ssl_trusted_certificate /etc/pki/tls/certs/ca-bundle.crt;\nproxy_ssl_verify_depth 3;\nproxy_ssl_verify on;\n'
  printf 'proxy_ssl_session_reuse on;\nproxy_http_version 1.1;\n'
} > /etc/nginx/default.d/01-proxy-ssl.conf
{
  printf 'slice 5m;\nproxy_cache_key $uri$is_args$args$slice_range;\nproxy_set_header Range $slice_range;\nproxy_cache_revalidate on;\n'
  printf 'proxy_cache_use_stale error timeout updating;\nadd_header X-Cache-Status $upstream_cache_status;\nproxy_intercept_errors on;\n'
  printf 'proxy_cache wcs_cache;\nproxy_cache_lock on;\nproxy_cache_valid 200 206 8h;\nproxy_cache_valid any 5m;\n'
} > /etc/nginx/default.d/00-proxy-cache.conf
{
  printf 'location ~*\.(deb|exe|fs|img|iso|pdf|rpm|tar\.(bz2|gz|xz)|tgz|zip)$ {\nproxy_cache_valid 200 206 7d;\n}\n'
  printf 'location ~*vmlinuz {\nproxy_cache_valid 200 206 7d;\n}\n'
} > /etc/nginx/default.d/50-proxy-ext.conf

printf 'location ^~ /centos/ {\nproxy_pass https://mirrors.kernel.org/centos/;\n}\n' > /etc/nginx/default.d/centos.conf
printf 'location ^~ /ubuntu/ {\nproxy_pass https://mirrors.kernel.org/ubuntu/;\n}\n' > /etc/nginx/default.d/ubuntu.conf
printf 'location ^~ /fedora/ {\nproxy_pass https://mirrors.kernel.org/fedora/;\n}\n' > /etc/nginx/default.d/fedora.conf
printf 'location ^~ /epel/ {\nproxy_pass https://mirrors.kernel.org/fedora-epel/;\n}\n' > /etc/nginx/default.d/epel.conf

printf 'location ^~ /centos-altarch/ {\nproxy_pass http://mirror.centos.org/altarch/;\n}\n' > /etc/nginx/default.d/centos-altarch.conf

{
  printf 'location ^~ /OpenBSD/ {\nproxy_pass https://mirrors.sonic.net/pub/OpenBSD/;\n}\n'
  printf 'location ^~ /openbsd/ {\nrewrite ^/openbsd(.*) /OpenBSD$1 last;\n}\n'
  printf 'location ^~ /pub/OpenBSD/ {\nrewrite ^/pub(.*)$ $1 last;\n}\n'
} > /etc/nginx/default.d/openbsd.conf

printf 'location ^~ /opensuse/ {\nproxy_pass http://download.opensuse.org/;\n}\n' > /etc/nginx/default.d/opensuse.conf

printf 'location ^~ /gnupg/ {\nproxy_pass https://gnupg.org/ftp/gcrypt/;\n}\n' > /etc/nginx/default.d/gnupg.conf
printf 'location ^~ /libgfshare/ {\nproxy_pass http://www.digital-scurf.org/files/libgfshare;\n}\n' > /etc/nginx/default.d/libgfshare.conf
printf 'location ^~ /yk-piv/ {\nproxy_pass https://developers.yubico.com/yubico-piv-tool/Releases/;\n}\n' > /etc/nginx/default.d/yk-piv.conf

printf 'location ^~ /copr-arrjay/ {\nproxy_pass https://copr-be.cloud.fedoraproject.org/results/arrjay/;\n}\n' > /etc/nginx/default.d/copr-arrjay.conf

printf 'location ^~ /hashicorp/ {\nproxy_pass https://releases.hashicorp.com/;\n}\n' > /etc/nginx/default.d/hashicorp.conf

nginx -t

mkdir -p /etc/systemd/system/nginx.service.requires
ln -s /etc/systemd/system/nginxdir.service /etc/systemd/system/nginx.service.requires/nginxdir.service
ln -s /usr/lib/systemd/system/nginx.service /etc/systemd/system/multi-user.target.wants/nginx.service
