#!/bin/bash -xe
# This script mounts a block storage volume by first formatting the storage device
# then mounting it, afterwards we bind the directory /var/www/html to the mount 
# todo find a better way of getting the block storage device name in ubuntu
mkfs.ext4 /dev/vdd
mkdir -p /mnt/block-storage
mount /dev/vdd /mnt/block-storage
mkdir -p /mnt/block-storage/html
mkdir -p /mnt/block-storage/mysql
mkdir -p /var/www/html/
mount -o bind /mnt/block-storage/html /var/www/html/
