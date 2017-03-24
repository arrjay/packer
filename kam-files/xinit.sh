#!/bin/sh

set -e

pkg_add slim

echo "numlock off" >> /etc/slim.conf
echo "default_user root" >> /etc/slim.conf
echo "auto_login yes" >> /etc/slim.conf

cp /etc/X11/xinit/xinitrc /root/.xinitrc

sed -e 's@# start some.*@xsetroot -solid crimson@' -i /root/.xinitrc

rcctl enable slim
