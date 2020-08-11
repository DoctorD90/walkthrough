# Clonezilla Custom Live ISO

## Introduction
Create a Live ISO version of [Clonezilla](https://clonezilla.org) with personal customizations.
A bootable ISO will be produced with options to:
- run the custom embeded script (default boot option)
- run as a default official version

In this guide I will adopt 3 custom files for the boot and 1 custom script to be embeded

|File|Description|
|:--|:--|
|grub.cfg|Custom version of the clonezilla released one|
|isolinux.cfg|Custom version of the clonezilla released one|
|syslinux.cfg|Custom version of the clonezilla released one|
|ocs-custom|Custom Script|

## Steps
### Preparations
Download in this folder the latest available [Zip version](https://clonezilla.org/downloads.php); for personal choices I opted for:
- Release: Stable (Debian based)
- CPU architecture: AMD64 (uEFI support)

Install the required software
```
sudo apt-get update
sudo apt-get install squashfs-tools xorriso
```
Create a variable with the name and version for an easy future update
```
myfile=clonezilla-live-2.6.7-28-amd64
```
Create subfolders to keep all organized
```
mkdir -p ./custom/{zip-tmp,squashfs-tmp}
```

### Operations
Unzip the downloaded zip file
```
unzip "$myfile".zip -d ./custom/zip-tmp`
```
Unpack the original `filesystem.squashfs`
```
sudo unsquashfs -d ./custom/squashfs-tmp/squashfs-root/ ./custom/zip-tmp/live/filesystem.squashfs
```
Include the custom script `ocs-custom` in the new `filesystem.squashfs`
```
sudo cp ./cfg/ocs-custom ./custom/squashfs-tmp/squashfs-root/usr/sbin/ocs-custom
sudo chmod 755 ./custom/squashfs-tmp/squashfs-root/usr/sbin/ocs-custom
```
Create the custom `filesystem.squashfs` and replace the old one
```
sudo rm -rf ./custom/squashfs-tmp/filesystem.squashfs.new
sudo mksquashfs ./custom/squashfs-tmp/squashfs-root ./custom/squashfs-tmp/filesystem.squashfs.new -b 1024k -comp xz -Xbcj x86 -e boot -info -check-data
sudo cp ./custom/squashfs-tmp/filesystem.squashfs.new ./custom/zip-tmp/live/filesystem.squashfs
```
Update the loader menu files; the main changes are:
- default new entry to lunch our script
- choice timer reduced
- options modified: _quite_ (removed), _noeject_ (added), _locales_ (configured to _en_US.UTF-8_), _keyboard-layouts_ (configured to _it_)
```
cp ./cfg/grub.cfg ./custom/zip-tmp/boot/grub/grub.cfg
cp ./cfg/isolinux.cfg ./custom/zip-tmp/syslinux/isolinux.cfg
cp ./cfg/syslinux.cfg ./custom/zip-tmp/syslinux/syslinux.cfg
sudo chmod 644 ./custom/zip-tmp/{boot/grub/grub.cfg,syslinux/isolinux.cfg,syslinux/syslinux.cfg}
```
Create the custom personalized Clonezilla ISO and hash it for future checks
```
xorriso -as mkisofs -R -r -J -joliet-long -l -cache-inodes -iso-level 3 -isohybrid-mbr ./custom/squashfs-tmp/squashfs-root/usr/lib/ISOLINUX/isohdpfx.bin -partition_offset 16 -A "$myfile"-custom -V "$myfile" -b syslinux/isolinux.bin -c syslinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot --efi-boot boot/grub/efi.img -isohybrid-gpt-basdat -isohybrid-apm-hfsplus ./custom/zip-tmp/ -o ./"$myfile"-custom.iso
md5sum "$myfile"-custom.iso > "$myfile"-custom.iso.md5
sha1sum "$myfile"-custom.iso > "$myfile"-custom.iso.sha1
sha256sum "$myfile"-custom.iso > "$myfile"-custom.iso.sha256
sha512sum "$myfile"-custom.iso > "$myfile"-custom.iso.sha512
```
Now you can burn it on a CD/DVD or on a USB Drive; for the USB drive you can use with `dd`
```
lsblk
sudo dd if="$myfile"-custom.iso of=/dev/sdX bs=1M status=progress
```
>replace *sdX* with the correct _dev_

## References
1. [The boot parameters for Clonezilla live](https://clonezilla.org/fine-print-live-doc.php?path=clonezilla-live/doc/99_Misc/00_live-boot-parameters.doc)
2. [How can I add a program in the main file system of Clonezilla live?](https://drbl.org/faq/fine-print.php?path=./2_System/81_add_prog_in_filesystem-squashfs.faq#81_add_prog_in_filesystem-squashfs.faq)
3. [How can I create Clonezilla live iso file from clonezilla live zip file?](https://drbl.org/faq/fine-print.php?path=./2_System/87_create_clonezilla_iso_from_zip.faq#87_create_clonezilla_iso_from_zip.faq)
