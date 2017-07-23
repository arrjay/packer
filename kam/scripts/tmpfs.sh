#!/bin/sh

set -e

# this results in an unused disk partition but...I don't care.
sed -e 's@.* /tmp .*@swap /tmp mfs rw,async,-s300M 0 0@' -i /etc/fstab

# make rc.securelevel do our permissions lift.
echo 'chmod 1777 /tmp' >> /etc/rc.securelevel
