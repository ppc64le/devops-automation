#!/bin/bash -xe
# This scripts installs and initializes mongodb
# If external storage is setup it will mount the external storage for use
sudo apt-get update && \
   sudo apt-get install -y mongodb-server jq 
# initialize mongodb

EXTERNAL_STORAGE="${EXTERNAL_STORAGE:-/tmp/scripts/}"
APP_DIR=$EXTERNAL_STORAGE"/app"
ENV_FILE=$EXTERNAL_STORAGE"app/database-api/env.sh"

sed -i "/#/d" $ENV_FILE 
sed -i -E "s/(API_AUTH_PASSWORD=).*/\1${API_AUTH_PASSWORD}/g" $ENV_FILE 
sed -i -E "s/(API_DB_PASSWORD=).*/\1${API_DB_PASSWORD}/g" $ENV_FILE 
sed -i -E "s/(API_ROOT_DB_PASSWORD=).*/\1${API_ROOT_DB_PASSWORD}/g" $ENV_FILE 
sed -i -E "s/(API_UI_PASSWORD=).*/\1${API_UI_PASSWORD}/g" $ENV_FILE 
sed -i -E "s/(API_DB_USERNAME=).*/\1${API_DB_USERNAME}/g" $ENV_FILE 
export $(xargs < $ENV_FILE)
export MONGO_INITDB_ROOT_USERNAME="${API_ROOT_DB_USERNAME}" 
export MONGO_INITDB_ROOT_PASSWORD="${API_ROOT_DB_PASSWORD}"
export MONGO_INITDB_ROOT_PORT="${API_DB_PORT}"
export MONGO_INITDB_DATABASE="${API_DB_NAME}"
export MONGO_NON_ROOT_USERNAME="${API_DB_USERNAME}"
export MONGO_NON_ROOT_PASSWORD="${API_DB_PASSWORD}"
bash $APP_DIR/database-api/mongodb/mongo-init.sh
sed -i -E "s/#(auth.*)/\1/g" /etc/mongodb.conf
sudo service mongodb restart
# initialize external storage
[[ $EXTERNAL_STORAGE  !=  "/tmp/scripts/" ]] && {
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
