#!/bin/bash

set -eux

[ ! -z "${TRANSIT_VLAN_ID}" ]
[ ! -z "${VIRTHOST_VLAN_ID}" ]
[ ! -z "${TRANSIT_IP}" ]
[ ! -z "${VIRTHOST_IP}" ]
[ ! -z "${DEFAULT_GW_IP}" ]

zypper install -y vlan

# this configures interfaces for _next_ reboot
sed -i -e 's/^BOOTPROTO=.*/BOOTPROTO='\''none'\''/' /etc/sysconfig/network/ifcfg-eth0
{
  printf "STARTMODE='auto'\n"
  printf "BOOTPROTO='static'\n"
  printf "IPADDR=%s\n" "${TRANSIT_IP}"
  printf "VLAN='yes'\n"
  printf "ETHERDEVICE='eth0'\n"
} > "/etc/sysconfig/network/ifcfg-vlan${TRANSIT_VLAN_ID}"

{
  printf "STARTMODE='auto'\n"
  printf "BOOTPROTO='static'\n"
  printf "IPADDR=%s\n" "${VIRTHOST_IP}"
  printf "VLAN='yes'\n"
  printf "ETHERDEVICE='eth0'\n"
} > "/etc/sysconfig/network/ifcfg-vlan${VIRTHOST_VLAN_ID}"

printf 'default %s - -\n' > /etc/sysconfig/network/routes "$(dirname ${DEFAULT_GW_IP})"
