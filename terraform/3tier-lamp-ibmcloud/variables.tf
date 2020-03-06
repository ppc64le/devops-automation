################################################################
# Module to deploy a VM with specified applications installed
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Licensed Materials - Property of IBM
#
# ©Copyright IBM Corp. 2020
#
################################################################
variable "ibmcloud_api_key" {
    description = "Denotes the IBM Cloud API key to use"
}

variable "basename" {
  description = "Denotes the name of the VPC to deploy into. Resources associated will be prepended with this name."
  default = "three-tier-web"
}

variable "vpc_region" {
  description = "Target region to create this instance"
  default = "us-south"
}

variable "vm_profile" {
  description = "VM profile to provision"
  default = "cp2-2x4"
}

variable "subnets" {
  description = "Should we create a vpc for this VM"
  type = "list"
  default = ["0,0", "1,1"]
}

variable "zone" {
  description = "Should we create a vpc for this VM"
  type = "string"
  default = "us-south-3" 
}

variable "security_groups" {
  description = "Comma separated "
  type = "list"
  default = ["22,80","22,3306"]
}

variable "db_password" {
  description = "Database password for initial db configuraion"
  type = "string"
  default = "none" 
}

variable "app_password" {
  description = "Application Password to use when initially configuring the Wordpress application"
  type = "string"
  default = "someverylongpasswordsome12" 
}

variable "app_user" {
  description = "Username created for initial Wordpress setup"
  type = "string"
  default = "admin" 
}

variable "app_title" {
  description = "Wordpress Title Name"
  type = "string"
  default = "MyWordpressBlog" 
}

variable "app_user_email" {
  description = "Email to use for Wordpress initialization"
  type = "string"
  default = "someemail@email.com" 
}


#################################################
##               End of variables              ##
#################################################
