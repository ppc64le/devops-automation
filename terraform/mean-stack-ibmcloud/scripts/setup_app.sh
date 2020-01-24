#!/bin/bash -xe 
# This scripts sets up the main mean app in the corect directory
# builds and renders the angular scripts
# installs forever to simplifyy running application
EXTERNAL_STORAGE="${EXTERNAL_STORAGE:-/mnt/mean}"
mkdir -p $EXTERNAL_STORAGE 
git clone https://github.com/jjalvare/mean $EXTERNAL_STORAGE 
cd $EXTERNAL_STORAGE && yarn && yarn install
echo "Starting application ..."
cp .env.example .env
npm install forever -g
secret=$(uuidgen)
sed -i -E 's/(SERVER_PORT=).*/\180/g' .env 
sed -i -E "s/(JWT_SECRET=).*/\1$secret/g" .env 
sed -i -E "s/(NODE_ENV=).*/\1production/g" .env 
sed -i -E "s/.*home works!/            Welcome to your exciting new app!/g" /mnt/mean/src/app/home/home.component.html
yarn build
forever start server/index.js
