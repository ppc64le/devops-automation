####################################################
##################### VARIABLES ####################
####################################################
variable "net1_vlan_id" {
  description = "VLAN ID"
}

variable "net1_subnet" {
  description = "Network1 Subnet x.x.x.x/x"
}

variable "net1_gateway" {
  description = "Network1 gateway"
}

variable "net1_start" {
  description = "Network1 starting IP address"
}

variable "net1_end" {
  description = "Network1 ending IP address"
}

####################################################
################ NETWORK RESOURCES #################
####################################################
resource "openstack_networking_network_v2" "net1" {
  name           = "${var.net1_name}"
  admin_state_up = "true"
  shared         = "true"

  segments {
    segmentation_id = "${var.net1_vlan_id}"
    network_type    = "vlan"
  }
}

resource "openstack_networking_subnet_v2" "net1-subnet" {
  name       = "${var.net1_name}_subnet"
  network_id = "${openstack_networking_network_v2.net1.id}"
  cidr       = "${var.net1_subnet}"
  gateway_ip = "${var.net1_gateway}"

  allocation_pool {
    start = "${var.net1_start}"
    end   = "${var.net1_end}"
  }

  ip_version      = 4
  dns_nameservers = ["${var.dns1}"]
}