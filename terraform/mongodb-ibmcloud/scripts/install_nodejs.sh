#!/bin/bash -xe 
# This script installs nodejs from binary
# Updates path
# Installs angular globally 
# Installs yarn for easiness of use
NODE=node-$VERSION-$DISTRO.tar.xz
export NG_CLI_ANALYTICS=ci
sudo mkdir -p /usr/local/lib/nodejs
echo "Getting Node: "$NODE
wget https://nodejs.org/dist/$VERSION/$NODE -O /tmp/$NODE
sudo tar -xJvf /tmp/$NODE -C /usr/local/lib/nodejs
export PATH=/usr/local/lib/nodejs/node-$VERSION-$DISTRO/bin:$PATH
echo "Installing angular globally ..."
npm install -g @angular/cli 
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install yarn -y
echo "Installation of Nodejs, Angular, Yarn complete ..."
