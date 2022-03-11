#!/bin/bash
[ -d /mnt/ramdisk ] && sudo umount -f -l /mnt/ramdisk && sleep 2
[ -d /mnt/ramdisk ] && sudo rmdir /mnt/ramdisk && echo -e "Done man!\n"
