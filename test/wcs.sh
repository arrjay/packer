#!/bin/sh

qemu-img create -f qcow2 output-qemu-wcs/data.qcow2 36G
qemu-system-x86_64 -drive file=output-qemu-wcs/system.qcow2,if=virtio,snapshot=on -drive file=output-qemu-wcs/data.qcow2,if=virtio,snapshot=on
