#!/bin/sh

qemu-img create -f qcow2 output-qemu-kam/black.qcow2 2G
guestfish -a output-qemu-kam/black.qcow2 << GUESTFISH_CMDS
run
part-init /dev/sda mbr
part-add /dev/sda p 512 -1
mke2fs /dev/sda1 label:black
GUESTFISH_CMDS
qemu-img create -f qcow2 -b system.img output-qemu-kam/transient.qcow2
qemu-system-x86_64 -machine accel=kvm -net nic,model=virtio -net user -usbdevice tablet -drive file=output-qemu-kam/transient.qcow2,if=virtio,snapshot=on -drive file=output-qemu-kam/black.qcow2,if=virtio,snapshot=on -display vnc=127.0.0.1:28 -chardev stdio,id=char0 -mon chardev=char0,mode=readline,default
