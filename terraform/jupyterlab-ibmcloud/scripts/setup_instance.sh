#!/bin/bash
# Grab docker image and load jupyter lab in VM
# Output token for user
SSH_HOST=$SSH_IP
export PATH=$PATH:/usr/local/cuda/bin
docker_app="jjalvare/tensorflow-gpu-jupyter:latest"
app="tensorflow-gpu-jupyter"
docker run -d -it --runtime=nvidia --rm --name=$app -e PYTHONPATH='/root/anaconda2/envs/wmlce/lib/python3.6/site-packages' -e PATH="$PATH:/root/anaconda2/envs/wmlce/bin/" -v $(realpath ~/notebooks):/tf/notebooks -p 80:8888 $docker_app 
sleep 30 # ensure we can get token
output=$(docker logs $app | sed -n "s/.*or http.*?token=\(.*\)/\1/p" | tail -n 1)
echo "Jupyter Lab Web Server at: http://${SSH_HOST}/?token=${output}"
