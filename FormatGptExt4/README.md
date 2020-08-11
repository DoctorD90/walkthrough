# Format a Device or a File with GPT schema and Ext4 Filesystem from terminal

## Introduction
Most of the time I have to simply and fastly format a linux device.
Im used to GParted tool but for simple partitioning schema I prefer the terminal console.
Let's format a device with GPT schema and ext4 filesystem.

## Steps for a Device
### Preparations
Install the required software
```
sudo apt-get update
sudo apt-get install parted
```
To identify the device you run the below command before & after to plug-in the device and compare the output.
*If you already know your configuration, it will be easier.*
```
lsblk
```
Create a variable with the device name
```
mydev=/dev/sdX
```
Create a variable with the device label
```
mylab=Disk_Label
```

### Operations
Format it with the GPT schema
```
sudo parted "$mydev" mklabel gpt
```
Create only one partition (*ignore the error*)
```
sudo parted -a opt "$mydev" mkpart primary ext4 0% 100%
```
Format it as EXT4 and take the ownership
```
sudo mkfs.ext4 -E root_owner="$(id -u):$(id -g)" -L "$mylab" "$mydev"p1
```

## Steps for an Image File
### Preparations
Create a variable with the image file name
```
myfile=imagedisk.iso
```
Create a variable with the device label
```
mylab=Disk_Label
```
Create a variable with the size of disk in MB
```
mysize=100
```

### Operations
Create the image file using `dd` command with size in MB *(100MB in example)*
```
sudo dd if=/dev/urandom of="$myfile" bs=1M count="$mysize"
```
Mount the file as loop device
```
sudo losetup -fP "$myfile"
```
Identify the loop device added (*/dev/loopX*) and create the variable to store it
```
mydev="$(sudo losetup -j "$myfile"|cut -d: -f1)"
```
Format it with the GPT schema
```
sudo parted "$mydev" mklabel gpt
```
Create only one partition (*ignore the error*)
```
sudo parted "$mydev" mkpart primary ext4 0% 100%
```
Format it as EXT4 and take the ownership
```
sudo mkfs.ext4 -E root_owner="$(id -u):$(id -g)" -L "$mylab" "$mydev"p1
```
Unount the file as loop device
```
sudo losetup -d "$mydev"
```

## References
*- None -*
