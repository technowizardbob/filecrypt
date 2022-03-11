#!/bin/bash

# NOTE /mnt/ssh.enc is a link to USB drive with said file.

if [ ! -r "/mnt/ssh.enc" ];
then
   echo "Insert usb key"
   exit 1
fi
[ ! -f /dev/ram0 ] && sudo mkfs -t ext2 -q /dev/ram0 4M
[ ! -d /mnt/ramdisk ] && sudo mkdir -p /mnt/ramdisk
sudo mount /dev/ram0 /mnt/ramdisk
sudo filecrypt -o /mnt/ramdisk -k ~/.config/filecrypt/tts.key -u /mnt/ssh.enc
sudo chown -R $USER:$USER /mnt/ramdisk
#sudo chmod -R 600 /mnt/ramdisk
sudo chmod 755 /mnt/ramdisk
