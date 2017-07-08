#!/bin/bash

set -eux
set -o pipefail

yum -y install nginx

ln -s /usr/lib/systemd/system/nginx.service /etc/systemd/system/multi-user.target.wants/nginx.service
