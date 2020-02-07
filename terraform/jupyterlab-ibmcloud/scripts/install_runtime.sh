#!/bin/bash -xe
# Install nvidia runtim in daemon.json and reload docker
echo '{
  "runtimes": {
  "nvidia": {
      "path": "/usr/bin/nvidia-container-runtime",
      "runtimeArgs": []
      }
  }
}' > /etc/docker/daemon.json
systemctl start nvidia-persistenced 
systemctl enable nvidia-persistenced 
sudo pkill -SIGHUP dockerd
sudo systemctl restart docker
echo "SUCCESS: nvidia-runtime started!"
