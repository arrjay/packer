#!/bin/sh

set -ex

ip2dec() {
  # Convert an IPv4 IP number to its decimal equivalent.
  local a b c d
  IFS=. read a b c d <<-_EOF_
$1
_EOF_
  echo "$(((a<<24)+(b<<16)+(c<<8)+d))"
}

dec2ip() {
  # Convert an IPv4 decimal IP value to an IPv4 IP.
  local a=$((~(-1<<8))) b=$1
  set -- "$((b>>24&a))" "$((b>>16&a))" "$((b>>8&a))" "$((b&a))"
  local IFS=.
  echo "$*"
}

[ ! -z "${IPADDRESS}" ]

# we also need to know all the ifw addresses (to make subnets)
[ ! -z "${IFW1_NETMGMT_IP}" ]
[ ! -z "${IFW1_USER_IP}" ]
[ ! -z "${IFW1_DMZ_IP}" ]
[ ! -z "${IFW1_VIRTHOST_IP}" ]
[ ! -z "${IFW1_RESTRICTEDUSER_IP}" ]
[ ! -z "${STANDARD_DHCP_GAP}" ]
[ ! -z "${VIRTHOST_DHCP_GAP}" ]

yum install -y dhcp

std_dns1=$(dirname "${DNSFW1_IP}")

mycidr=$(basename "${IPADDRESS}")
myaddr=$(echo "${IPADDRESS}" | sed 's@/'"${mycidr}"'@@')
mynet=$(ipcalc -n "${IPADDRESS}" | cut -f2 -d=)
mymask=$(ipcalc -m "${IPADDRESS}" | cut -f2 -d=)

# unwind all the other network numbers
netmgmt_net=$(ipcalc -n "${IFW1_NETMGMT_IP}" | cut -f2 -d=)
netmgmt_mask=$(ipcalc -m "${IFW1_NETMGMT_IP}" | cut -f2 -d=)
netmgmt_min=$(dec2ip $(($(ip2dec ${netmgmt_net}) + ${STANDARD_DHCP_GAP})))
netmgmt_max=$(dec2ip $(($(ip2dec $(ipcalc -b "${IFW1_NETMGMT_IP}" | cut -f2 -d=)) - 1)))
netmgmt_rtr=$(dirname "${IFW1_NETMGMT_IP}")

user_net=$(ipcalc -n "${IFW1_USER_IP}" | cut -f2 -d=)
user_mask=$(ipcalc -m "${IFW1_USER_IP}" | cut -f2 -d=)
user_min=$(dec2ip $(($(ip2dec ${user_net}) + ${STANDARD_DHCP_GAP})))
user_max=$(dec2ip $(($(ip2dec $(ipcalc -b "${IFW1_USER_IP}" | cut -f2 -d=)) - 1)))
user_rtr=$(dirname "${IFW1_USER_IP}")

dmz_net=$(ipcalc -n "${IFW1_DMZ_IP}" | cut -f2 -d=)
dmz_mask=$(ipcalc -m "${IFW1_DMZ_IP}" | cut -f2 -d=)
dmz_min=$(dec2ip $(($(ip2dec ${dmz_net}) + ${STANDARD_DHCP_GAP})))
dmz_max=$(dec2ip $(($(ip2dec $(ipcalc -b "${IFW1_DMZ_IP}" | cut -f2 -d=)) - 1)))
dmz_rtr=$(dirname "${IFW1_DMZ_IP}")

vhost_net=$(ipcalc -n "${IFW1_VIRTHOST_IP}" | cut -f2 -d=)
vhost_mask=$(ipcalc -m "${IFW1_VIRTHOST_IP}" | cut -f2 -d=)
vhost_min=$(dec2ip $(($(ip2dec ${vhost_net}) + ${VIRTHOST_DHCP_GAP})))
vhost_max=$(dec2ip $(($(ip2dec $(ipcalc -b "${IFW1_VIRTHOST_IP}" | cut -f2 -d=)) - 1)))
vhost_rtr=$(dirname "${IFW1_VIRTHOST_IP}")

restrict_net=$(ipcalc -n "${IFW1_RESTRICTEDUSER_IP}" | cut -f2 -d=)
restrict_mask=$(ipcalc -m "${IFW1_RESTRICTEDUSER_IP}" | cut -f2 -d=)
restrict_min=$(dec2ip $(($(ip2dec ${restrict_net}) + ${STANDARD_DHCP_GAP})))
restrict_max=$(dec2ip $(($(ip2dec $(ipcalc -b "${IFW1_RESTRICTEDUSER_IP}" | cut -f2 -d=)) - 1)))
restrict_rtr=$(dirname "${IFW1_RESTRICTEDUSER_IP}")

{
  printf 'subnet %s netmask %s {\n}\n' "${mynet}" "${mymask}"

  printf 'subnet %s netmask %s{\n option subnet-mask %s;\n option routers %s;\n' "${netmgmt_net}" "${netmgmt_mask}" "${netmgmt_mask}" "${netmgmt_rtr}"
  printf ' option domain-name-servers %s;\n' "${std_dns1}"
  printf ' range %s %s;\n}\n' "${netmgmt_min}" "${netmgmt_max}"

  printf 'subnet %s netmask %s{\n option subnet-mask %s;\n option routers %s;\n' "${user_net}" "${user_mask}" "${user_mask}" "${user_rtr}"
  printf ' option domain-name-servers %s;\n' "${std_dns1}"
  printf ' range %s %s;\n}\n' "${user_min}" "${user_max}"

  printf 'subnet %s netmask %s{\n option subnet-mask %s;\n option routers %s;\n' "${dmz_net}" "${dmz_mask}" "${dmz_mask}" "${dmz_rtr}"
  printf ' option domain-name-servers %s;\n' "${std_dns1}"
  printf ' range %s %s;\n}\n' "${dmz_min}" "${dmz_max}"

  printf 'subnet %s netmask %s{\n option subnet-mask %s;\n option routers %s;\n' "${vhost_net}" "${vhost_mask}" "${vhost_mask}" "${vhost_rtr}"
  printf ' option domain-name-servers %s;\n' "${std_dns1}"
  printf ' range %s %s;\n}\n' "${vhost_min}" "${vhost_max}"

  printf 'subnet %s netmask %s{\n option subnet-mask %s;\n option routers %s;\n' "${restrict_net}" "${restrict_mask}" "${restrict_mask}" "${restrict_rtr}"
  printf ' option domain-name-servers %s;\n' "${std_dns1}"
  printf ' range %s %s;\n}\n' "${restrict_min}" "${restrict_max}"

} > /etc/dhcp/dhcpd.conf

dhcpd -t

chkconfig dhcpd on
