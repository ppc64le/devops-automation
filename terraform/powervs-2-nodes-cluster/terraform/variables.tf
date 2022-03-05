####################################################
##################### VARIABLES ####################
####################################################

variable "ibmcloud_region" {
  description = "IBM Cloud region to connect to"
  default     = "syd"
}

variable "ibmcloud_zone" {
  description = "IBM Cloud zone to connect to"
  default     = "syd05"
}

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key to use"
}

variable "node1_instance_name" {
  description = "The name of the Power Systems Virtual Server instance"
  default     = "bs-node1"
}

variable "node2_instance_name" {
  description = "The name of the Power Systems Virtual Server instance"
  default     = "bs-node2"
}

variable "service_instance_id" {
  description = "PowerVS Instance associated with the account"
}

variable "memory" {
  description = "Memory Of the Power VM Instance"
  default     = "8"
}

variable "processors" {
  description = "Processor Count on the server"
  default     = "0.2"
}

variable "proc_type" {
  description = "The type of processor mode in which the VM will run with 'shared', 'capped' or 'dedicated'"
  default     = "shared"
}

variable "pin_policy" {
  description = "The pinning policy of the instance"
  default     = "none"
}

variable "ssh_key_pair_name" {
  description = "The name of the SSH key that you want to use to access your Power Systems Virtual Server instance. The SSH key must be uploaded to IBM Cloud."
  default     = "bs-ssh-key"
}

variable "storage_type" {
  description = "Storage Pool for server deployment"
  default     = "tier3"
}

variable "network_name" {
  description = "network name to attach to the instance"
}

variable "system_type" {
  description = "The type of system on which to create the VM (s922/e880/e980)"
  default     = "s922"
}

variable "image_name" {
  description = "The ID of the image "
  default     = "7200-05-01"
}

variable "node1_ip" {
  description = "Private IP for Node1"
}

variable "node2_ip" {
  description = "Private IP for Node2"
}

variable "ansible_enabled" {
  description = "Enable Ansible configuration"
  default     = true
}

