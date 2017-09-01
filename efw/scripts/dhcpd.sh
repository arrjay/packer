#!/bin/sh

set -e

pkg_add sipcalc isc-dhcp-server

[ ! -z "${TRANSIT_IP}" ]
[ ! -z "${TRANSIT_DHCP_GAP}" ]

case "${PACKER_BUILDER_TYPE}" in
  qemu)		ifname=vio2 ;;
  vmware*)	ifname=vmx2 ;;
  *)		false ;;
esac

cdr2mask ()
{
   set -- $(( 5 - ($1 / 8) )) 255 255 255 255 $(( (255 << (8 - ($1 % 8))) & 255 )) 0 0 0
   [ $1 -gt 1 ] && shift $1 || shift
   echo ${1-0}.${2-0}.${3-0}.${4-0}
}

itoa ()
{
  echo -n $(($(($(($((${1}/256))/256))/256))%256)).
  echo -n $(($(($((${1}/256))/256))%256)).
  echo -n $(($((${1}/256))%256)).
  echo $((${1}%256)) 
}

tf_cidr=$(basename ${TRANSIT_IP})
tf_addr=$(echo ${TRANSIT_IP}|sed 's@/'${tf_cidr}'@@')
tf_mask=$(cdr2mask ${tf_cidr})
last_ip=$(sipcalc ${TRANSIT_IP}|awk '$0 ~ "Usable" { print $6 }')
subnet=$(sipcalc ${TRANSIT_IP}|awk -F'- ' '$0 ~ "Network address" { print $2 }')
ip_int=$(sipcalc ${subnet}|awk -F'- ' '$0 ~ "decimal" { print $2 }')
next_ip_int=$((${ip_int} + ${TRANSIT_DHCP_GAP}))
next_ip=$(itoa "${next_ip_int}")

rcctl enable isc_dhcpd

{
  printf 'ddns-update-style none;\n\n'
  printf 'option hashi-consul-servers code 84 = array of ip-address;\n\n'
  printf 'subnet %s netmask %s {\n' "${subnet}" "${tf_mask}"
  printf ' option hashi-consul-servers %s;\n' "${tf_addr}"
  printf ' option subnet-mask %s;\n' "${tf_mask}"
  printf ' range %s %s;\n' "${next_ip}" "${last_ip}"
  printf '}\n'
} > /etc/dhcpd.conf

/usr/local/sbin/dhcpd -t -cf /etc/dhcpd.conf
