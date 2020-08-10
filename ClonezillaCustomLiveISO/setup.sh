#!/bin/bash

myfile=clonezilla-live-2.6.7-28-amd64

mkdir -p ./custom/{zip-tmp,squashfs-tmp}
unzip "$myfile".zip -d ./custom/zip-tmp
sudo unsquashfs -d ./custom/squashfs-tmp/squashfs-root/ ./custom/zip-tmp/live/filesystem.squashfs
sudo cp ./cfg/ocs-custom ./custom/squashfs-tmp/squashfs-root/usr/sbin/ocs-custom
sudo chmod 755 ./custom/squashfs-tmp/squashfs-root/usr/sbin/ocs-custom
sudo rm -rf ./custom/squashfs-tmp/filesystem.squashfs.new
sudo mksquashfs ./custom/squashfs-tmp/squashfs-root ./custom/squashfs-tmp/filesystem.squashfs.new -b 1024k -comp xz -Xbcj x86 -e boot -info -check-data
sudo cp ./custom/squashfs-tmp/filesystem.squashfs.new ./custom/zip-tmp/live/filesystem.squashfs
cp ./cfg/grub.cfg ./custom/zip-tmp/boot/grub/grub.cfg
cp ./cfg/isolinux.cfg ./custom/zip-tmp/syslinux/isolinux.cfg
cp ./cfg/syslinux.cfg ./custom/zip-tmp/syslinux/syslinux.cfg
sudo chmod 644 ./custom/zip-tmp/{boot/grub/grub.cfg,syslinux/isolinux.cfg,syslinux/syslinux.cfg}
xorriso -as mkisofs -R -r -J -joliet-long -l -cache-inodes -iso-level 3 -isohybrid-mbr ./custom/squashfs-tmp/squashfs-root/usr/lib/ISOLINUX/isohdpfx.bin -partition_offset 16 -A "$myfile"-custom -V "$myfile" -b syslinux/isolinux.bin -c syslinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot --efi-boot boot/grub/efi.img -isohybrid-gpt-basdat -isohybrid-apm-hfsplus ./custom/zip-tmp/ -o ./"$myfile"-custom.iso
sha512sum "$myfile"-custom.iso > "$myfile"-custom.iso.sha512

