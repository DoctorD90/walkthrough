#!/bin/bash

myfile=imagedisk.iso
mylab=Disk_Label
mysize=100

sudo dd if=/dev/urandom of="$myfile" bs=1M count="$mysize"
sudo losetup -fP "$myfile"
mydev="$(sudo losetup -j "$myfile"|cut -d: -f1)"
sudo parted "$mydev" mklabel gpt
sudo parted "$mydev" mkpart primary ext4 0% 100%
sudo mkfs.ext4 -E root_owner="$(id -u $WHOAMI):$(id -g $WHOAMI)" -L "$mylab" "$mydev"p1
sudo losetup -d "$mydev"
