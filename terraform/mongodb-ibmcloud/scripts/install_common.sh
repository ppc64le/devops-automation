#!/bin/bash -xe
# Scripts sets up comon packages for later use by driver and tools
until sudo apt-get update; do sleep 5;done
echo "Install common packages"
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    python3-dev python3-pip python3 git gnupg2 pass build-essential python3-venv 
    
echo "Setup Python 3"
update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

echo "SUCCESS: common packages are now installed!"
