#####################################################################
##
##      Created 11/18/19 by admin. for oradbaas
##
#####################################################################

## REFERENCE {"openstack_network":{"type": "openstack_reference_network"}}

terraform {
  required_version = "> 0.8.0"
}

provider "openstack" {
  insecure    = true
  version = "~> 1.2"
}

resource "openstack_compute_instance_v2" "dbserver" {
  name      = "${format("${var.dbserver_name}-${var.dbserver_user_data}-${local.local_dbserver_ts}")}"
  image_name  = "${var.openstack_image_name}"
  flavor_name = "${var.openstack_flavor_name}"
  user_data = "${format("DBNAME=%s",var.dbserver_user_data)}"
  network {
    uuid = "${var.openstack_network_id}"
  }
}

