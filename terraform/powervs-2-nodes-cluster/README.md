# Deploy a PowerHA 2-nodes cluster using Terraform and Ansible on IBM Power Systems Virtual Server 

Deploy two AIX 7.2 VMs with shared volumes for CAA and DATA using Terraform. Install and configure PowerHA NFSv3 Server using Ansible.

## Prerequisites 

1. Terraform = 1.1.6
2. IBM Cloud Terraform Provider ~> 1.39.0 
3. IBM Power Systems Virtual Server Service
4. A private network is required for communication between different Power Systems Virtual Server instances (cluster nodes)
5. IBM Cloud API Key with authorization to provision in IBM Power Systems Virtual Server Service
6. Upload you public SSH key to the BM Power Systems Virtual Server Service
7. PowerHA installation software


## Overview

This deployment provisions:
  1. Creates an anti-affinity placement group  
  2. Creates two 10Gb disks for CAA from different storage controllers using volume anti-affinit policy
  3. Creates two AIX 7.2 VMs in the placement group from step 1 and with rootvg disks in the same controllers with CAA disks from step 2
  4. Creates two 50Gb data volumes from two different storage controllers using volume anti-affinit policy and attach it to both cluster nodes
  5. Install and Configure PowerHA to export a redundant shared volumed (mirror pools) as NFSv3 Server 


To run the example, you will need to:

1. Clone this Git repository
2. Obtain your [IBM Cloud API key](https://cloud.ibm.com) (needed for step #4)
3. Obtain PowerHA installation files and create a tar.gz file and copy it to ansible/files directory
4. Update the terraform.tfvars file to suit your needs
5. Update the Ansible inventory files with hostnames, IPs and cluster variables


## Provision Environment in IBM Power Systems Virtual Server with terraform
Next, you can run the example by invoking...

The planning phase (validates the Terraform configuration)

```shell
cd terraform
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



