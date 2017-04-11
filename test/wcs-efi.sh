#!/bin/bash

qemu-img create -f qcow2 output-qemu-wcs/data.qcow2 36G
qemu-img create -f qcow2 -b system.qcow2 output-qemu-wcs/transient.qcow2
qemu-system-x86_64 -m 512 -machine accel=kvm -net nic,model=virtio -net user -drive file=/usr/share/edk2.git/ovmf-x64/OVMF_CODE-pure-efi.fd,if=pflash,format=raw,unit=0,readonly=on -drive file=output-qemu-wcs-nvram.fd,if=pflash,format=raw,unit=1 -drive file=output-qemu-wcs/transient.qcow2,if=virtio,snapshot=on -drive file=output-qemu-wcs/data.qcow2,if=virtio,snapshot=on
#rm output-qemu-wcs/transient.qcow2
#rm output-qemu-wcs/data.qcow2

