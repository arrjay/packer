#!/bin/sh

# start X via ttys so we just, you know, are.
sed -e 's@^ttyC4.*@ttyC4 "/usr/X11R6/bin/startx -- :0" xorg on@' -i /etc/ttys
