locals {
  port_ids = "${split(",", var.tcp_ports)}" 
}

resource "ibm_is_vpc" "vpc" {
  name = "${var.basename}-vpc"
}

resource ibm_is_subnet "subnet" {
  name = "${var.basename}-subnet"
  vpc  = "${ibm_is_vpc.vpc.id}"
  zone = "${var.vpc_zone}"
  ip_version = "ipv4"
  total_ipv4_address_count = 16
}

# Create an SSH key which will be used for provisioning by this template, and for debug purposes
resource "ibm_is_ssh_key" "public_key" {
  name = "${var.basename}-public-key"
  public_key = "${tls_private_key.ssh_key_keypair.public_key_openssh}"
}

# Create a public floating IP so that the app is available on the Internet
resource "ibm_is_floating_ip" "fip1" {
  name = "${var.basename}-fip"
  target = "${ibm_is_instance.vm.primary_network_interface.0.id}"
}

resource "ibm_is_security_group_rule" "sg1-tcp-rule" {
  count = "${length(split(",", var.tcp_ports))}" 
  depends_on = [
    "ibm_is_floating_ip.fip1"
  ]
  group = "${ibm_is_vpc.vpc.default_security_group}"
  direction = "inbound"
  remote = "0.0.0.0/0"

  tcp = {
    port_min = "${element(local.port_ids, count.index)}"
    port_max = "${element(local.port_ids, count.index)}"
  }
}

resource "ibm_is_instance" "vm" {
  name = "${var.basename}-vm1"
  image = "${var.boot_image_id}"
  profile = "${var.vm_profile}"

  primary_network_interface = {
    subnet = "${ibm_is_subnet.subnet.id}"
  }

  vpc = "${ibm_is_vpc.vpc.id}"
  zone = "${var.vpc_zone}"
  keys      = ["${ibm_is_ssh_key.public_key.id}"]
  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# Create a ssh keypair which will be used to provision code onto the system - and also access the VM for debug if needed.
resource "tls_private_key" "ssh_key_keypair" {
  algorithm = "RSA"
  rsa_bits = "2048"
}
