#!/bin/bash

SOURCE_ZIP="https://downloads.raspberrypi.org/raspbian_lite_latest"

sum=$(sha256sum "raspbian.zip"|cut -d ' ' -f1) 2>/dev/null
#2017-04-10
if [ "${sum}" != "ada1e462ecfb0ef1375c26473bd874a3471c7b3fc367242ad08fb3a73c0895d9" ] ; then
 curl -L "${SOURCE_ZIP}" -o "raspbian.zip"
fi

set -e

image=$(zipinfo -1 "raspbian.zip")

unzip -o "raspbian.zip"

mkdir -p output-qemu-quo/workfiles

mv -f "${image}" output-qemu-quo/system.img
truncate -s4G "output-qemu-quo/system.img"

parted "output-qemu-quo/system.img" resizepart 2 100%

# grab the UUID of the FS volumes as we're about to rewrite /etc/fstab
fsuuid=$(guestfish --ro -a "output-qemu-quo/system.img" run : blkid /dev/sda2 | awk -F: '$1 == "UUID" { print $2 }')
fsuuid=${fsuuid//[[:space:]]}
bootuuid=$(guestfish --ro -a "output-qemu-quo/system.img" run : blkid /dev/sda1 | awk -F: '$1 == "UUID" { print $2 }')
bootuuid=${bootuuid//[[:space:]]}

cat > output-qemu-quo/workfiles/fstab <<_EOF_
proc            /proc           proc    defaults          0       0
UUID=${bootuuid}  /boot           vfat    defaults          0       2
UUID=${fsuuid}  /               ext4    defaults,noatime  0       1
_EOF_

# ssh _user_ keys
rm -f output-qemu-quo/workfiles/ssh_user_rsa_key*
ssh-keygen -f output-qemu-quo/workfiles/ssh_user_rsa_key -N '' -t rsa

cp output-qemu-quo/workfiles/ssh_user_rsa_key.pub output-qemu-quo/workfiles/authorized_keys

# (re)generate ssh host keys as raspbian...doesn't exactly like the qemu machine handed it.
rm -f output-qemu-quo/workfiles/ssh_host_rsa_key*
ssh-keygen -f output-qemu-quo/workfiles/ssh_host_rsa_key -N '' -t rsa

# make guestfish mangle the image pre-boot
# drive guestfish about, modifying a raspbian image to do what we want on boot.
guestfish <<_EOF_
add output-qemu-quo/system.img
run
resize2fs /dev/sda2
mount /dev/sda2 /
copy-in output-qemu-quo/workfiles/fstab /etc
mkdir /home/pi/.ssh
copy-in output-qemu-quo/workfiles/authorized_keys /home/pi/.ssh
copy-in output-qemu-quo/workfiles/ssh_host_rsa_key /etc/ssh
ln-s /lib/systemd/system/ssh.service /etc/systemd/system/multi-user.target.wants/ssh.service
_EOF_

curl -L -o output-qemu-quo/workfiles/vmlinuz http://mko.wcs.bbxn.us/fedora/releases/25/Server/armhfp/os/images/pxeboot/vmlinuz
curl -L -o output-qemu-quo/workfiles/initrd.img http://mko.wcs.bbxn.us/fedora/releases/25/Server/armhfp/os/images/pxeboot/initrd.img

tmux -L varm start-server
tmux -L varm new-session -d -s qemu \
 qemu-system-arm \
  -kernel output-qemu-quo/workfiles/vmlinuz \
  -initrd output-qemu-quo/workfiles/initrd.img \
  -m 1024 -M virt-2.6 -no-reboot \
  -append "console=ttyAMA0 rw root=UUID=${fsuuid} rootwait rdloaddriver=vfat rd_NO_LVM rd_NO_LUKS rd_NO_MD rd_NO_MDIMSM rd_NO_DM" \
  -hda output-qemu-quo/system.img \
  -net user,hostfwd=tcp:127.0.0.1:8222-:22 -net nic,model=virtio -nographic

./build.sh packer/quo.json
