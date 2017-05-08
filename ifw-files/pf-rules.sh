#!/bin/sh

set -ex

# okay I was mean and took advantage of set -e
[ ! -z "${CABLE_MODEM_IP}" ]
[ ! -z "${NMS_NETWORK}" ]
[ ! -z "${DNS_NETWORK}" ]

case "${PACKER_BUILDER_TYPE}" in
  qemu)         transit=vio0 ;;
  vmware*)      transit=vmx0 ;;
  *)            false ;;
esac

{
  # tables
  printf 'table <martians> persist {\n'
  for x in 0.0.0.0/8 10.0.0.0/8 100.64.0.0/10 127.0.0.0/8 169.254.0.0/16 \
           172.16.0.0/12 192.0.0.0/24 192.0.2.0/24 192.168.0.0/16 192.18.0.0/15 \
           198.51.100.0/24 203.0.113.0/24
   do
     printf ' %s\n' "${x}"
   done
  printf '\n}\n'

  # skips
  printf 'set skip on lo\n'
  printf '\n'

  # diverts
  printf 'anchor "ftp-proxy/*"\n'
  printf 'pass in on { dmz virthosts netmgmt standard restricted } inet proto tcp to port ftp flags S/SA modulate state divert-to 127.0.0.1 port 8021\n'
  printf '\n'

  # block ipv6 ra without logging
  printf 'block drop quick inet6 proto icmp6 all icmp6-type { routeradv, routersol }\n'
  # filter start
  printf 'block return log\n'
  printf '\n'

  # antispoof
  printf 'pass out quick on dmz proto udp from port { 67, 68 } to %s port 67\n' "${NMS_NETWORK}"
  printf 'antispoof quick for { dmz virthosts netmgmt standard restricted vmm }\n'
  printf '\n'

  # filter continue
  ## pings
  for net in egress dmz virthosts netmgmt standard restricted ; do
    printf 'pass out on %s inet proto icmp from (%s) icmp-type echoreq\n' "${net}" "${net}"
    printf 'pass in on %s inet proto icmp to (%s) icmp-type echoreq\n' "${net}" "${net}"
  done

  # vmm
  printf 'block out quick on vmm from !(vmm)\n'
  printf 'pass on vmm from (vmm) to (vmm:network)\n'
  printf 'block in on vmm\n'

  # netmgmt can talk to nms:22 ; nms can talk to netmgmt:{ 22, 23, 80, 443 }
  printf 'pass proto tcp from %s to (netmgmt:network) port { 22, 23, 80, 443 }\n' "${NMS_NETWORK}"
  printf 'pass proto tcp from (netmgmt:network) to %s port 22\n' "${NMS_NETWORK}"

  # nms can talk to cable modem
  printf 'pass from %s to %s\n' "${NMS_NETWORK}" "${CABLE_MODEM_IP}"

  # dns
  printf 'pass proto { tcp, udp } from any to %s port 53\n' "${DNS_NETWORK}"
  printf 'pass proto { tcp, udp } from %s to any port 53\n' "${DNS_NETWORK}"

  # dhcp
  printf 'pass proto icmp from %s to <martians> icmp-type echoreq\n' "${NMS_NETWORK}"
  for net in virthosts netmgmt standard restricted ; do
    printf 'pass in on %s proto udp from port 68 to port 67\n' "${net}"
  done

  # ntp
  printf 'pass proto udp from (netmgmt:network) to %s port 123\n' "${NMS_NETWORK}"

  # standard users, doing standard user things ( ssh, http, https, ircs )
  printf 'pass in on standard proto { tcp } to !<martians> port { 22, 80, 443, 6697 }\n'

  # transit
  printf 'pass in on %s to (%s)\n' "${transit}" "${transit}"
  printf 'pass out on %s from (%s)\n' "${transit}" "${transit}"
} > /etc/pf.conf

pfctl -n -f /etc/pf.conf

echo 'net.inet.ip.forwarding=1' >> /etc/sysctl.conf
