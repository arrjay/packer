#!/bin/sh

set -e

mv /tmp/daily.local /etc/daily.local
chmod 0744 /etc/daily.local
