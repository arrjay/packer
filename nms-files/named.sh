#!/usr/bin/env bash

set -e

[ ! -z "${NMS1_DNS_KEY_TYPE}" ]
[ ! -z "${NMS1_DNS_KEY_DATA}" ]
[ ! -z "${SOA_CONTACT}" ]

arpait () {
  local IFS
  IFS=.
  set -- $1
  echo $3.$2.$1
}

yum -y install bind bind-utils

dmz_start=$(ipcalc -n ${IFW1_DMZ_IP}|awk -F. '{print $4}')
dmz_end=$(ipcalc -b ${IFW1_DMZ_IP}|awk -F. '{print $4}')
dmz_mask=$(basename ${IFW1_DMZ_IP})
virt_start=$(ipcalc -n ${IFW1_VIRTHOST_IP}|awk -F. '{print $4}')
virt_end=$(ipcalc -b ${IFW1_VIRTHOST_IP}|awk -F. '{print $4}')
virt_mask=$(basename ${IFW1_VIRTHOST_IP})
netmgmt1_start=$(ipcalc -n ${IFW1_NETMGMT_IP}|awk -F. '{print $4}')
netmgmt1_end=$(ipcalc -b ${IFW1_NETMGMT_IP}|awk -F. '{print $4}')
netmgmt1_mask=$(basename ${IFW1_NETMGMT_IP})
ruser_start=$(ipcalc -n ${IFW1_RESTRICTEDUSER_IP}|awk -F. '{print $4}')
ruser_end=$(ipcalc -b ${IFW1_RESTRICTEDUSER_IP}|awk -F. '{print $4}')
ruser_mask=$(basename ${IFW1_RESTRICTEDUSER_IP})

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
    printf '  file "data/%s.produxi.net";\n' "${stub}"
    printf '  allow-update {key "nms1.";};\n'
    printf '};\n'
  done

  printf 'zone "%s.in-addr.arpa" IN {\n' $(arpait $(dirname "${IFW1_DMZ_IP}"))
  printf '  type master;\n'
  printf '  file "data/%s.in-addr.arpa";\n' $(arpait $(dirname "${IFW1_DMZ_IP}"))
  printf '  allow-update {none;};\n'
  printf '};\n'

  printf 'zone "%s.in-addr.arpa" IN {\n' $(arpait $(dirname "${IFW1_NETMGMT_IP}"))
  printf '  type master;\n'
  printf '  file "data/%s.in-addr.arpa";\n' $(arpait $(dirname "${IFW1_NETMGMT_IP}"))
  printf '  allow-update {none;};\n'
  printf '};\n'

  printf 'zone "%s.in-addr.arpa" IN {\n' $(arpait $(dirname "${IFW1_RESTRICTEDUSER_IP}"))
  printf '  type master;\n'
  printf '  file "data/%s.in-addr.arpa";\n' $(arpait $(dirname "${IFW1_RESTRICTEDUSER_IP}"))
  printf '  allow-update {none;};\n'
  printf '};\n'

  for arpa in $(arpait $(dirname "${IFW1_USER_IP}")) "${ruser_start}/${ruser_mask}.$(arpait $(dirname ${IFW1_RESTRICTEDUSER_IP}))" \
              "${netmgmt1_start}/${netmgmt1_mask}.$(arpait $(dirname ${IFW1_NETMGMT_IP}))" \
              "${dmz_start}/${dmz_mask}.$(arpait $(dirname ${IFW1_DMZ_IP}))" "${virt_start}/${virt_mask}.$(arpait $(dirname ${IFW1_VIRTHOST_IP}))" ; do
    printf 'zone "%s.in-addr.arpa" IN {\n' ${arpa}
    printf '  type master;\n'
    printf '  file "data/%s.in-addr.arpa";\n' $(echo ${arpa} | sed 's@/@_@g')
    printf '  check-names ignore;\n'
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

for arpa in $(arpait $(dirname "${IFW1_USER_IP}")) "${ruser_start}_${ruser_mask}.$(arpait $(dirname ${IFW1_RESTRICTEDUSER_IP}))" \
            "${netmgmt1_start}_${netmgmt1_mask}.$(arpait $(dirname ${IFW1_NETMGMT_IP}))" \
            "${dmz_start}_${dmz_mask}.$(arpait $(dirname ${IFW1_DMZ_IP}))" "${virt_start}_${virt_mask}.$(arpait $(dirname ${IFW1_VIRTHOST_IP}))" ; do
  {
    printf '$TTL 1d\n@ SOA @ %s. 1 2d 1d 1w 12h\n' "${SOA_CONTACT}"
    printf '@\tNS\tnms1.dmz.produxi.net.\n'
  } > /var/named/data/${arpa}.in-addr.arpa
done

{
  printf 'nms1\tA\t%s\n' $(dirname "${IPADDRESS}")
} >> /var/named/data/dmz.produxi.net

{
  printf '$TTL 1d\n@ SOA @ %s. 1 2d 1d 1w 12h\n' "${SOA_CONTACT}"
  printf '@\tNS\tnms1.dmz.produxi.net.\n'
  printf '$GENERATE %s-%s $ CNAME $.%s/%s\n' "${dmz_start}" "${dmz_end}" "${dmz_start}" "${dmz_mask}"
  printf '$GENERATE %s-%s $ CNAME $.%s/%s\n' "${virt_start}" "${virt_end}" "${virt_start}" "${virt_mask}"
} > /var/named/data/$(arpait $(dirname "${IFW1_DMZ_IP}")).in-addr.arpa

{
  printf '$TTL 1d\n@ SOA @ %s. 1 2d 1d 1w 12h\n' "${SOA_CONTACT}"
  printf '@\tNS\tnms1.dmz.produxi.net.\n'
  printf '$GENERATE %s-%s $ CNAME $.%s/%s\n' "${netmgmt1_start}" "${netmgmt1_end}" "${netmgmt1_start}" "${netmgmt1_mask}"
} > /var/named/data/$(arpait $(dirname "${IFW1_NETMGMT_IP}")).in-addr.arpa

{
  printf '$TTL 1d\n@ SOA @ %s. 1 2d 1d 1w 12h\n' "${SOA_CONTACT}"
  printf '@\tNS\tnms1.dmz.produxi.net.\n'
  printf '$GENERATE %s-%s $ CNAME $.%s/%s\n' "${ruser_start}" "${ruser_end}" "${ruser_start}" "${ruser_mask}"
} > /var/named/data/$(arpait $(dirname "${IFW1_RESTRICTEDUSER_IP}")).in-addr.arpa

named-checkconf -z /etc/named.conf

systemctl enable named

firewall-cmd --permanent --zone public --add-service dns
