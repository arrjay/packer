#!/bin/bash

set -eux

[ ! -z "${TRANSIT_VLAN_ID}" ]
[ ! -z "${VIRTHOST_VLAN_ID}" ]
[ ! -z "${QUO_TRANSIT_IP}" ]
[ ! -z "${QUO_VIRTHOST_IP}" ]

zypper install vlan

# this configures interfaces for _next_ reboot
sed -i -e 's/^BOOTPROTO=.*//' /etc/sysconfig/network-scripts/ifcfg-eth0
{
  printf "STARTMODE='auto'\n"
  printf "BOOTPROTO='static'\n"
  printf "IPADDR=%s\n" "${QUO_TRANSIT_IP}"
  printf "VLAN='yes'\n"
  printf "ETHERDEVICE='eth0'\n"
} > "/etc/sysconfig/network/ifcfg-vlan${TRANSIT_VLAN_ID}"

{
  printf "STARTMODE='auto'\n"
  printf "BOOTPROTO='static'\n"
  printf "IPADDR=%s\n" "%{QUO_VIRTHOST_IP}"
  printf "VLAN='yes'\n"
  printf "ETHERDEVICE='eth0'\n"
} > "/etc/sysconfig/network/ifcfg-vlan${VIRTHOST_VLAN_ID}"
