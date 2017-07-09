#!/bin/sh

# set bsd.mp as default kernel if installed
if [ -f /etc/boot.conf ] && [ -f /bsd.mp ]; then
  echo 'set image bsd.mp' > /etc/boot.conf
fi
