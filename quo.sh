#!/bin/bash

# gpg --recv-keys 0xB88B2FD43DBDC284

SOURCE="http://download.opensuse.org/ports/armv6hl/tumbleweed/images/openSUSE-Tumbleweed-ARM-JeOS-raspberrypi.armv6l-Current.raw.xz"
SUM="http://download.opensuse.org/ports/armv6hl/tumbleweed/images/openSUSE-Tumbleweed-ARM-JeOS-raspberrypi.armv6l-Current.raw.xz.sha256"

curl -LO "${SUM}"

gpg --verify "$(basename ${SUM})"
if [ $? -ne 0 ] ; then echo "uh" ; exit 1 ; fi

if [ ! -e "$(basename ${SOURCE})" ] ; then
  curl -LO "${SOURCE}"
fi

storedsum=$(grep "$(basename ${SOURCE} -Current.raw.xz)" "$(basename ${SUM})"|cut -d' ' -f1)
sum=$(sha256sum "$(basename ${SOURCE})"|cut -d ' ' -f1) 2>/dev/null
if [ "${sum}" != "${storedsum}" ] ; then
  exit 2
fi

set -e

mkdir -p output-qemu-quo/workfiles

xzcat "$(basename ${SOURCE})" > output-qemu-quo/system.img
diskid=$(sfdisk -l "output-qemu-quo/system.img" | awk -F': ' '$1 ~ "Disk identifier" { print $2 }')
diskid=${diskid:2}

truncate -s4G "output-qemu-quo/system.img"

parted "output-qemu-quo/system.img" resizepart 2 100%

# this crazy thing patches the partition uuid pack to the clone
newdisk_hex=$(dd if=output-qemu-quo/system.img bs=512 count=1 2> /dev/null | xxd -s +432 | head -n1)
dm_hex=""
dcount=0
for w in $newdisk_hex ; do
  ((dcount++))
  case $dcount in
    6)
      w=${diskid:6:2}${diskid:4:2}
      ;;
    7)
      w=${diskid:2:2}${diskid:0:2}
      ;;
    *)
      :
      ;;
  esac
  dm_hex="${dm_hex}${w} "
done

echo "${dm_hex}" | xxd -r - output-qemu-quo/system.img

guestfish <<_EOF_
add output-qemu-quo/system.img
run
resize2fs /dev/sda2
_EOF_

curl -L -o output-qemu-quo/workfiles/vmlinuz http://mko.wcs.bbxn.us/fedora/releases/25/Server/armhfp/os/images/pxeboot/vmlinuz
curl -L -o output-qemu-quo/workfiles/initrd.img http://mko.wcs.bbxn.us/fedora/releases/25/Server/armhfp/os/images/pxeboot/initrd.img

tmux -L varm start-server
tmux -L varm new-session -d -s qemu \
 qemu-system-arm \
  -kernel output-qemu-quo/workfiles/vmlinuz \
  -initrd output-qemu-quo/workfiles/initrd.img \
  -m 1024 -M virt-2.6 -no-reboot \
  -append "console=ttyAMA0 rw root=/dev/vda2 rootwait rdloaddriver=vfat rd_NO_LVM rd_NO_LUKS rd_NO_MD rd_NO_MDIMSM rd_NO_DM net.ifnames=0" \
  -hda output-qemu-quo/system.img \
  -net user,hostfwd=tcp:127.0.0.1:8222-:22 -net nic,model=virtio -nographic

./build.sh packer/quo.json
