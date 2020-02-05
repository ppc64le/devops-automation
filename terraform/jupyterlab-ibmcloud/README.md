# Deploy a JupyterLab Workspace on IBM Cloud VPC 

Deploy a JupyterLab on Ubuntu 18.04 ppc64le running in IBM Cloud VPC. Within a JupyterLab one can run Python code interactively,
enable code in a text file for scientific research, drop down into a bash terminal, in a flexible and integrated manner. 
Whats even more exciting this JuypterLab is setup to support GPU workloads where you can train your Artificial Intelligence 
model at very fast speeds, literally supercomputer fast.

## Prerequisites 

1. Terraform >= 0.11.14 
2. IBM Cloud Terraform Provider >= 0.20.0 
3. IBM Cloud API Key with authorization to provision in IBM Cloud VPC 

## Overview

This deployment:
  1. Creates a Linux Ubuntu ppc64le VM server on IBM Cloud VPC 
  2. Creates a new ssh key to login 
  3. Opens Ports 80, 443 in VPC Security Group port to access the JupyterLab Workspace 
  4. Opens Port 22 to access SSH console
  5. Sets up GPU Driver 418.39 and starts services
  6. Loads CUDA 10.1 Libraries to interact in docker environment
  7. Downloads JupyterLab from Docker hub: jjalvare/tensorflow-gpu-jupyter
  8. Run jjalvare/tensorflow-gpu-jupyter as tensorflow-gpu-jupyter

### Install Complete 
After install you can access the default JupyterLab web page of Ubuntu VM by IP:

    http://<IP>/?token=<token> 

The token can be found in your output of Terraform:

```console
null_resource.provisioners (remote-exec): Jupyter Lab Web Server at: http://192.168.1.68/?token=72d5sometokenwithaverylongnumberbae1c53
```


### Validate GPUs are correctly loaded 
#### Notebook 

```python
import tensorflow as tf
tf.test.is_gpu_available(
    cuda_only=False,
    min_cuda_compute_capability=None
)
```

#### VM in docker container 
Login to VM
```console
ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no"  -i id_rsa root@<IP>
```
Execute shell in docker container
```
docker exec -it tensorflow-gpu-jupyter bash
```
Activate environment
```
conda activate wmlce
```
Change to benchmark tool directory
```
cd /root/anaconda2/envs/wmlce/tf_cnn_benchmarks/
```
Run resnet50 on GPUs through benchmark tool 
```
python tf_cnn_benchmarks.py --num_gpus=2 --batch_size=32 --model=resnet50 --variable_update=parameter_server
```

Output should show:
```
Running warm up
2020-02-03 15:41:40.438629: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcublas.so.10
2020-02-03 15:41:41.023369: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcudnn.so.7
Done warm up
Step	Img/sec	total_loss
1	images/sec: 630.1 +/- 0.0 (jitter = 0.0)	8.063
10	images/sec: 633.9 +/- 1.0 (jitter = 4.6)	7.653
20	images/sec: 634.0 +/- 1.2 (jitter = 5.0)	7.752
30	images/sec: 633.5 +/- 1.2 (jitter = 6.1)	7.899
40	images/sec: 633.9 +/- 1.0 (jitter = 5.1)	7.867
50	images/sec: 633.8 +/- 0.9 (jitter = 6.2)	7.752
60	images/sec: 634.2 +/- 0.8 (jitter = 5.1)	7.955
70	images/sec: 634.5 +/- 0.7 (jitter = 4.4)	7.997
80	images/sec: 634.2 +/- 0.6 (jitter = 3.9)	7.937
90	images/sec: 634.2 +/- 0.6 (jitter = 4.6)	7.882
100	images/sec: 634.8 +/- 0.6 (jitter = 4.7)	7.742
----------------------------------------------------------------
total images/sec: 634.28
----------------------------------------------------------------
```

## Run template
To run the example, you will need to:

1. Clone this Git repository
2. [Download and configure](https://github.com/IBM-Cloud/terraform-provider-ibm) the IBM Cloud Terraform provider (minimally v0.20.0 or later)
3. Obtain your [IBM Cloud API key](https://cloud.ibm.com) (needed for step #4)
4. Update the variables.tf file to suit your needs

## Provision Environment in IBM Cloud with Terraform
Next, you can run the example by invoking...

The planning phase (validates the Terraform configuration)

```shell
terraform init
terraform plan
```

The apply phase (provisions the infrastructure)

```shell
terraform apply
```

The destroy phase (deletes the infrastructure)

```shell
terraform destroy
```
