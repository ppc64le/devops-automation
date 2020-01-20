# Deploy a LAMP stack using Terraform on IBM Cloud Gen 2 

Deploy a Linux Apache Mariadb PHP (LAMP) stack on Ubuntu 18.04 ppc64le running in IBM Cloud Gen 2

## Pre-Requisites 

1. Terraform >= 0.11.14 
2. IBM Cloud Terraform Provider >= 0.20.0 
3. IBM Cloud API Key 

## Overview

This deployment provisions a LAMP Stack running in IBM Cloud on a  Ubuntu ppc64le VM. 

After install you can access the default web page of Ubuntu VM by IP:

    https://<IP>/  

To validate Mariadb successful connection:  

    https://<IP>/todo_list.php 

For information on system run:  
  
    https://<IP>/info.php 

To run the example, you will need to:

1. Clone this Git repository
2. [Download and configure](https://github.com/IBM-Cloud/terraform-provider-ibm) the IBM Cloud Terraform provider (minimally v0.20.0 or later)
3. Obtain your [IBM Cloud API key](https://cloud.ibm.com) (needed for step #4)
4. Update the variables.tf file to suit your needs

## Provision Environment in IBM Cloud
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

