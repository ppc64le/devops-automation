#!/bin/bash -xe
echo "Add docker repository"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
arch=`dpkg --print-architecture`
add-apt-repository "deb [arch=${arch}] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get -y install  docker-ce docker-compose
echo "SUCCESS: Docker is now installed!"
