#!/usr/bin/env bash

set -e

[ ! -z "${NMS1_DNS_KEY_TYPE}" ]
[ ! -z "${NMS1_DNS_KEY_DATA}" ]
[ ! -z "${SOA_CONTACT}" ]

yum -y install bind bind-utils

{
  printf 'key nms1. {\n'
  printf '  algorithm %s;\n' "${NMS1_DNS_KEY_TYPE//_/-}"
  printf '  secret "'
  # print out 56 character chunks
  slide=0
  set +e
  while [ $((slide + 56)) -lt ${#NMS1_DNS_KEY_DATA} ] ; do
    set -e
    printf '%s ' "${NMS1_DNS_KEY_DATA:${slide}:56}"
    slide=$((slide + 56))
    set +e
  done
  set -e
  printf '%s";\n' "${NMS1_DNS_KEY_DATA:${slide}}"
  printf '};\n'
} > /etc/named.update.key

{
  printf 'options {\n'
  printf '  directory "/var/named";\n'
  printf '  dump-file       "/var/named/data/cache_dump.db";\n'
  printf '  statistics-file "/var/named/data/named_stats.txt";\n'
  printf '  memstatistics-file "/var/named/data/named_mem_stats.txt";\n'
  printf '  recursion no;\n'
  printf '  pid-file "/run/named/named.pid";\n'
  printf '  session-keyfile "/run/named/session.key";\n'
  printf '};\n\n'

  printf 'logging {\n'
  printf '  channel default_debug {\n'
  printf '    file "data/named.run";\n'
  printf '    severity dynamic;\n'
  printf '  };\n'
  printf '};\n'

  for stub in dyn netmgmt virthosts dmz ; do
    printf 'zone "%s.produxi.net" IN {\n' "${stub}"
    printf '  type master;\n'
    printf '  file "data/%s.produxi.net"\n;' "${stub}"
    printf '  allow-update {key "nms1.";};\n'
    printf '};\n'
  done

  printf 'include "/etc/named.update.key";\n'
} > /etc/named.conf

for stub in dyn netmgmt virthosts dmz ; do
  {
    printf '$TTL 1d\n@ SOA @ %s. 1 2d 1d 1w 12h\n' "${SOA_CONTACT}"
    printf '@\tNS\tnms1.dmz.produxi.net.\n'
  } > /var/named/data/${stub}.produxi.net
done

{
  printf 'nms1\tA\t%s\n' $(dirname "${IPADDRESS}")
} >> /var/named/data/dmz.produxi.net

cat /etc/named.conf

named-checkconf -z /etc/named.conf

systemctl enable named

firewall-cmd --permanent --zone public --add-service dns
