# Deploy a Mongodb stack using Terraform on IBM Cloud VPC 

Deploy MongoDB and Mongo Express on Ubuntu 18.04 ppc64le running in IBM Cloud VPC

## Prerequisites 

1. Terraform = 0.11.14 
2. IBM Cloud Terraform Provider = 0.20.0 
3. IBM Cloud API Key with authorization to provision in IBM Cloud VPC and IBM Cloud Block Storage for VPC 

## Overview

This deployment:
  1. Creates a Linux Ubuntu ppc64le VM server on IBM Cloud VPC 
  2. Creates a new ssh key to login 
  3. Opens Ports 80, 443 in VPC Security Group port to access web page 
  4. Opens Port 27017 in VPC Security Group port to access Mongodb Server 
  5. Opens Ports 22 to access SSH console
  6. Sets up Mongodb and Mongo Express packages and starts services
  7. Application files are mounted to /mnt/app 

After install you can access the default web page of Ubuntu VM by IP:

    http://<IP>/  

To validate MongoDB successful connection login to Monogo Express login page.

To run the example, you will need to:

1. Clone this Git repository
2. [Download and configure](https://github.com/IBM-Cloud/terraform-provider-ibm) the IBM Cloud Terraform provider (minimally v0.20.0 or later)
3. Obtain your [IBM Cloud API key](https://cloud.ibm.com) (needed for step #4)
4. Update the variables.tf file to suit your needs
## Provision Environment in IBM Cloud with IBM Cloud Schematics

### Create workspace 
![](./assets/images/create_workspace.png)
### Input Schematics Variables
![](./assets/images/retrieve_input_variables.png)
### Apply Workspace 
![](./assets/images/apply_workspace.png)
### Login to Mongo Express
### Create Collection


## Provision Environment in IBM Cloud with terraform
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



