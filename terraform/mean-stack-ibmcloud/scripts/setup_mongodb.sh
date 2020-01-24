#!/bin/bash -xe
# This scripts installs mongodb
# If external storage is setup it will mount the external storage for use
sudo apt-get update && \
   sudo apt-get install -y mongodb-server 

[[ -n $EXTERNAL_STORAGE ]] && {
    echo "Installing external storage for mongodb"
    mkfs.ext4 /dev/vdd
    DBPATH=/mnt/block-storage/db
    mkdir -p /mnt/block-storage
    mount /dev/vdd /mnt/block-storage
    mkdir -p /mnt/block-storage/app
    mkdir -p $DBPATH
    sudo service mongodb stop 
    rsync -av /var/lib/mongodb/ $DBPATH
    sudo chown mongodb:mongodb $DBPATH 
    sed -i -E 's/(dbpath=).+/\1\/mnt\/block-storage\/db/' /etc/mongodb.conf
    sudo service mongodb restart
}
echo "Installation of mongodb complete"
