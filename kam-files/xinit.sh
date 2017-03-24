#!/bin/sh

# start X via ttys so we just, you know, are.
sed -e 's@^ttyC4.*@ttyC4 "/usr/X11R6/bin/startx -- :0" xorg on@' -i /etc/ttys

# set the background to be less awful.
sed -e 's@# start some.*@xsetroot -solid crimson@' -i /etc/X11/xinit/xinitrc

# modify xinitrc to put keyboard focus back
printf '# force keyboard focus to vt4\nwsconsctl display.focus=4\n' >> /etc/X11/xinit/xinitrc
