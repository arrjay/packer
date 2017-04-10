#!/bin/sh

gpg-connect-agent -r /root/reset-yk-applet.gp
pkill scdaemon
pkill gpg-agent
