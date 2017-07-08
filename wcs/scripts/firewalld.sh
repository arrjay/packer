#!/bin/bash

set -eux
set -o pipefail

echo "configuring firewalld"
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=squid
