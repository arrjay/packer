#!/bin/sh

set -e

[ ! -z "${NETMGMT_IP}" ]
[ ! -z "${ST_USER_IP}" ]
[ ! -z "${DMZ_IP}" ]
[ ! -z "${VIRTHOST_IP}" ]
[ ! -z "${RES_USER_IP}" ]

case "${PACKER_BUILDER_TYPE}" in
  qemu)		ifbase=vio ;;
  vmware*)	ifbase=vmx ;;
  *)		false ;;
esac

{
  printf 'inet %s\n' "${DMZ_IP}"
  printf '-inet6\n'
  printf 'group dmz\n'
} > /etc/hostname.${ifbase}1

{
  printf 'inet %s\n' "${VIRTHOST_IP}"
  printf '-inet6\n'
  printf 'group virthosts\n'
} > /etc/hostname.${ifbase}2

{
  printf 'inet %s\n' "${NETMGMT_IP}"
  printf '-inet6\n'
  printf 'group netmgmt\n'
} > /etc/hostname.${ifbase}3

{
  printf 'inet %s\n' "${ST_USER_IP}"
  printf '-inet6\n'
  printf 'group standard\n'
} > /etc/hostname.${ifbase}4

{
  printf 'inet %s\n' "${RES_USER_IP}"
  printf '-inet6\n'
  printf 'group restricted\n'
} > /etc/hostname.${ifbase}5
