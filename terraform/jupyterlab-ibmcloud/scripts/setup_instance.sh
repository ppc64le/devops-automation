#!/bin/bash
# Grab docker image and load jupyter lab in VM
# Output token for user
SSH_HOST=$SSH_IP
export PATH=$PATH:/usr/local/cuda/bin
docker_app="ibmcom/tensorflow-ppc64le:1.15.0-gpu-py3-jupyter"
app="tensorflow-gpu-jupyter"
docker run -d -it --runtime=nvidia --rm --name=$app -v $(realpath ~/notebooks):/tf/notebooks -p 80:8888 $docker_app 
sleep 30 # ensure we can get token
output=$(docker logs $app | sed -n "s/.*or http.*?token=\(.*\)/\1/p" | tail -n 1)
echo "Jupyter Lab Web Server at: http://${SSH_HOST}/?token=${output}"
