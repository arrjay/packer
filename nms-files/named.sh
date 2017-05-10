#!/usr/bin/env bash

set -e

[ ! -z "${NMS1_DNS_KEY_TYPE}" ]
[ ! -z "${NMS1_DNS_KEY_DATA}" ]

yum -y install bind

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
