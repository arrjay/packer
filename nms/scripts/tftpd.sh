#!/bin/sh

set -e

yum -y install tftp-server

systemctl enable tftp.socket

firewall-cmd --zone=public --add-service=tftp --permanent
