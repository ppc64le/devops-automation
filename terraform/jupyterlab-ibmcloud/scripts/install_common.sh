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
    python3-dev python3-pip python3 git gnupg2 pass build-essential 
    
echo "Setup Python 3"
update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1
echo "Nvidia Runtime Repository"
curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) && curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list
echo "Add docker repository"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=ppc64el] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

echo "SUCCESS: common packages are now installed!"
