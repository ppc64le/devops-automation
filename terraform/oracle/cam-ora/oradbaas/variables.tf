#####################################################################
##
##      Created 11/18/19 by admin. for oradbaas
##
#####################################################################

variable "dbserver_name" {
  type = "string"
  description = " db server VM name prefix. Oracle dbname and a timestamp will be appended in the PowerVC VM name."
}

variable "openstack_image_name" {
  type = "string"
  description = "PowerVC image name"
}

variable "openstack_flavor_name" {
  type = "string"
  description = "flavor name, or PowerVC compute template)"
}

variable "openstack_network_id" {
  type = "string"
  description = "Network id in PowerVC"
}

variable "dbserver_user_data" {
  type = "string"
  description = "Oracle DB name"
}

locals {
  local_dbserver_ts = "${replace(replace(replace(substr(timestamp(),2,17),"-",""),"T","_"),":","")}"
}
