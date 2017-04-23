#!/bin/bash

inst_hook cmdline 99 "$moddir/parse-growpart.sh"

dracut_install growpart
dracut_install sfdisk
