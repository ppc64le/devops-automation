####################################################
##################### VARIABLES ####################
####################################################
#PowerVC (OpenStack) 1.4.2.x
#---------------------------------
variable "powervc_user" {
  description = "powervc user name"
}

variable "powervc_server" {
  description = "powervc server ip"
}

variable "powervc_password" {
  description = "powervc password"
}

variable "powervc_project" {
  description = "powervc project (tenant name)"
  default     = "ibm-default"
}


####################################################
#################### PROVIDERS #####################
####################################################
provider "openstack" {
  user_name   = "${var.powervc_user}"
  password    = "${var.powervc_password}"
  tenant_name = "${var.powervc_project}"
  domain_name = "Default"
  #region      = "RegionOne"
  auth_url = "https://${var.powervc_server}:5000/v3/"
  insecure = true

  #version                        = "~> 0.3"
}
