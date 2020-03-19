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
locals {
  db_password = "${var.db_password == "none"?random_password.db_password.result:var.db_password}"
  app_password = "${var.app_password == "none"?random_password.app_password.result:var.app_password}"
  db_name = "wordpress"
  basename = "${format("%s-%s", var.basename, random_string.random_name.result)}"
  db_user = "root"
  subnets = ["0,0", "1,1"]
  security_groups = ["22,80","22,3306"] 
}

resource "random_password" "db_password" {
  length = 16
  special = true
  override_special = "!@_"
}

resource "random_string" "random_name" {
  length = 8
  special = true
  lower = true
  upper = false 
  number = false 
  special = false 
}

resource "random_password" "app_password" {
  length = 16
  special = true
  override_special = "!@_"
}


resource "ibm_is_vpc" "vpc" {
  name = "${local.basename}-vpc"
}

resource "null_resource" "service_depends_on_cidr1" {
  triggers = {
    deps = "${jsonencode(element(ibm_is_vpc_address_prefix.cidr1.*.id, 0))}"
  }
}

resource "null_resource" "service_depends_on_cidr2" {
  triggers = {
    deps = "${jsonencode(element(ibm_is_vpc_address_prefix.cidr2.*.id, 1))}"
  }
}

resource ibm_is_subnet "subnet0" { 
  count = 0
  name = "${format("%s-subnet%03d", local.basename , 1)}"
  vpc  = "${ibm_is_vpc.vpc.id}"
  zone = "${var.zone}"
  ip_version = "ipv4"
  ipv4_cidr_block = "10.10.11.0/28"
  depends_on = ["null_resource.service_depends_on_cidr1"]
}

resource ibm_is_subnet "subnet1" { 
  count = 0
  name = "${format("%s-subnet%03d", local.basename , 2)}"
  vpc  = "${ibm_is_vpc.vpc.id}"
  zone = "${var.zone}"
  ip_version = "ipv4"
  ipv4_cidr_block = "10.10.12.0/28"
  depends_on = ["null_resource.service_depends_on_cidr2"]
}

resource ibm_is_subnet "subnet" {
  count = "${length(local.subnets)}"
  name = "${format("%s-subnet%03d", local.basename , count.index +1)}"
  vpc  = "${ibm_is_vpc.vpc.id}"
  zone = "${var.zone}"
  ip_version = "ipv4"
  ipv4_cidr_block = "${count.index == 0?"10.10.11.0/28":"10.10.12.0/28"}"
  depends_on = ["null_resource.service_depends_on_cidr1", "null_resource.service_depends_on_cidr2"]
}

resource "null_resource" "service_depends_on0" {
  triggers = {
    deps = "${jsonencode(element(ibm_is_subnet.subnet.*.id, 0))}"
  }
}

resource "null_resource" "service_depends_on1" {
  triggers = {
    deps = "${jsonencode(element(ibm_is_subnet.subnet.*.id, 1))}"
  }
}

resource "ibm_is_vpc_address_prefix" "cidr01" {
  count= 0
  name = "${format("%s-prefix%03d", local.basename , 1)}"
  zone = "${var.zone}"
  vpc  = "${ibm_is_vpc.vpc.id}"
  cidr = "10.10.11.0/28"
  depends_on = ["null_resource.service_depends_on0"]
}

resource "ibm_is_vpc_address_prefix" "cidr02" {
  count = 0
  name = "${format("%s-prefix%03d", local.basename , 2)}"
  zone = "${var.zone}"
  vpc  = "${ibm_is_vpc.vpc.id}"
  cidr = "10.10.12.0/28"
  depends_on = ["null_resource.service_depends_on1"]
}
resource "ibm_is_vpc_address_prefix" "cidr1" {
  count= 1
  name = "${format("%s-prefix%03d", local.basename , 1)}"
  zone = "${var.zone}"
  vpc  = "${ibm_is_vpc.vpc.id}"
  cidr = "10.10.11.0/28"
}

resource "ibm_is_vpc_address_prefix" "cidr2" {
  count = 1
  name = "${format("%s-prefix%03d", local.basename , 2)}"
  zone = "${var.zone}"
  vpc  = "${ibm_is_vpc.vpc.id}"
  cidr = "10.10.12.0/28"
}

#
data ibm_is_image "ubuntu" {
  name = "ibm-ubuntu-18-04-3-minimal-ppc64le-2"
}

# Create an SSH key which will be used for provisioning by this template, and for debug purposes
resource "ibm_is_ssh_key" "public_key" {
  name = "${local.basename}-public-key"
  public_key = "${tls_private_key.ssh_key_keypair.public_key_openssh}"
}

# Create an SSH key which will be used for provisioning by this template, and for debug purposes
# resource "ibm_is_ssh_key" "public_key" {
  # count = "${length(var.keys)}"
  # name = "${format("%s-public-key-%03d", local.basename , count.index +1)}"
  # public_key = "${element(var.keys, count.index)}"
# }
#


resource "ibm_is_security_group" "security_groups" {
    count = "${length(local.security_groups)}" 
    name = "${format("%s-sg-%03d", local.basename , count.index +1)}"
    vpc = "${ibm_is_vpc.vpc.id}"
}

resource "ibm_is_security_group_rule" "sg-tcp-rule" {
  count = "${length(split(",", local.security_groups[0])) *length(local.security_groups)}" 
  group = "${element(ibm_is_security_group.security_groups.*.id, count.index/ length(local.security_groups) )}" 
  direction = "inbound"
  remote = "0.0.0.0/0"
  tcp = {
    port_min = "${element(split(",", local.security_groups[count.index / length(local.security_groups)]), count.index % length(local.security_groups))}" 
    port_max = "${element(split(",", local.security_groups[count.index / length(local.security_groups)]), count.index % length(local.security_groups))}" 
  }
}

resource "ibm_is_security_group_rule" "sg-tcp-rule-all" {
  count = "${length(split(",", local.security_groups[0])) *length(local.security_groups)}" 
  group = "${element(ibm_is_security_group.security_groups.*.id, count.index/length(local.security_groups))}" 
  direction = "outbound"
  remote = "0.0.0.0/0"
}


resource "ibm_is_instance" "vm1" {
  name = "${format("%s-appserv-%03d", local.basename , 1)}"
  image = "${data.ibm_is_image.ubuntu.id}"
  profile = "${var.vm_profile}"
  primary_network_interface = {
    subnet = "${ibm_is_subnet.subnet.0.id}"
    security_groups = ["${ibm_is_security_group.security_groups.0.id}"]
  }
  network_interfaces = {
    subnet = "${ibm_is_subnet.subnet.1.id}"
    security_groups = ["${ibm_is_security_group.security_groups.1.id}"]
    name = "eth1"
  }

  vpc = "${ibm_is_vpc.vpc.id}"
  zone = "${var.zone}"
  keys      = ["${ibm_is_ssh_key.public_key.id}"]
  timeouts {
    create = "4m"
    delete = "4m"
  }
}

resource "ibm_is_instance" "vm2" {
  name = "${format("%s-appserv-%03d", local.basename , 2)}"
  image = "${data.ibm_is_image.ubuntu.id}"
  profile = "${var.vm_profile}"
  primary_network_interface = {
    subnet = "${element(ibm_is_subnet.subnet.*.id, 0)}"
    security_groups = ["${element(ibm_is_security_group.security_groups.*.id, 0)}"]
  }
  network_interfaces = {
    subnet = "${element(ibm_is_subnet.subnet.*.id, 1)}"
    security_groups = ["${element(ibm_is_security_group.security_groups.*.id, 1)}"]
    name = "eth1"
  }

  vpc = "${ibm_is_vpc.vpc.id}"
  zone = "${var.zone}"
  keys      = ["${ibm_is_ssh_key.public_key.id}"]
  timeouts {
    create = "4m"
    delete = "4m"
  }
}

resource "ibm_is_instance" "vm3" {
  name = "${format("%s-dbserv-%03d", local.basename , 3)}"
  image = "${data.ibm_is_image.ubuntu.id}"
  profile = "${var.vm_profile}"
  primary_network_interface = {
    subnet = "${element(ibm_is_subnet.subnet.*.id, 1)}"
    security_groups = ["${element(ibm_is_security_group.security_groups.*.id, 1)}"]
  }
  vpc = "${ibm_is_vpc.vpc.id}"
  zone = "${var.zone}"
  keys      = ["${ibm_is_ssh_key.public_key.id}"]
  timeouts {
    create = "4m"
    delete = "4m"
  }
}

resource "ibm_is_instance" "vm4" {
  name = "${format("%s-dbserv-%03d", local.basename , 4)}"
  image = "${data.ibm_is_image.ubuntu.id}"
  profile = "${var.vm_profile}"
  primary_network_interface = {
    subnet = "${element(ibm_is_subnet.subnet.*.id, 1)}"
    security_groups = ["${element(ibm_is_security_group.security_groups.*.id, 1)}"]
  }
  vpc = "${ibm_is_vpc.vpc.id}"
  zone = "${var.zone}"
  keys      = ["${ibm_is_ssh_key.public_key.id}"]
  timeouts {
    create = "4m"
    delete = "4m"
  }
}
#

#Create a public floating IP so that the instance is available on the Internet
resource "ibm_is_floating_ip" "fip1" {
  name = "${format("%s-fip-%03d", local.basename , 1)}"
  target = "${ibm_is_instance.vm1.primary_network_interface.0.id}" 
}

#Create a public floating IP so that the instance is available on the Internet
resource "ibm_is_floating_ip" "fip2" {
  name = "${format("%s-fip-%03d", local.basename , 2)}"
  target = "${ibm_is_instance.vm2.primary_network_interface.0.id}" 
}

#Create a public floating IP so that the instance is available on the Internet
resource "ibm_is_floating_ip" "fip3" {
  name = "${format("%s-fip-%03d", local.basename , 3)}"
  target = "${ibm_is_instance.vm3.primary_network_interface.0.id}" 
}

#Create a public floating IP so that the instance is available on the Internet
resource "ibm_is_floating_ip" "fip4" {
  name = "${format("%s-fip-%03d", local.basename , 4)}"
  target = "${ibm_is_instance.vm4.primary_network_interface.0.id}"
}
#
#Create a ssh keypair which will be used to provision code onto the system - and also access the VM for debug if needed.
resource "tls_private_key" "ssh_key_keypair" {
  algorithm = "RSA"
  rsa_bits = "2048"
}

resource "null_resource" "provisioner1" {

  triggers = {
    vmid = "${ibm_is_floating_ip.fip1.address}"
  }

  provisioner "file" {
    source =  "scripts"   
    destination = "/tmp"
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = "${ibm_is_floating_ip.fip1.address}"
      private_key = "${tls_private_key.ssh_key_keypair.private_key_pem}"
    }
  }
  
  provisioner "remote-exec" {
    inline = [
      "set -e",
      "export APP_PASSWORD=${local.app_password}",
      "export APP_USER=${var.app_user}",
      "export APP_EMAIL=${var.app_user_email}",
      "export APP_NAME=${var.app_title}",
      "export LB_HOSTNAME=${ibm_is_lb.lb.hostname}",
      "export DB_USER=${local.db_user}",
      "export DB_HOST=${ibm_is_instance.vm3.primary_network_interface.0.primary_ipv4_address}",
      "export SLAVE_DB_HOST=${ibm_is_instance.vm4.primary_network_interface.0.primary_ipv4_address}",
      "export DB_NAME=${local.db_name}",
      "export DB_PASSWORD=${local.db_password}",
      "export SCRIPT_PATH=/tmp/scripts/",
      "chmod -R u+x /tmp/scripts*/*",
      "/tmp/scripts/install_app.sh",
      "exit 0",
    ]
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = "${ibm_is_floating_ip.fip1.address}"
      private_key = "${tls_private_key.ssh_key_keypair.private_key_pem}"
    }
  }
}

resource "null_resource" "provisioner2" {

  triggers = {
    vmid = "${ibm_is_floating_ip.fip2.address}"
  }

  provisioner "file" {
    source =  "scripts"   
    destination = "/tmp"
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = "${ibm_is_floating_ip.fip2.address}"
      private_key = "${tls_private_key.ssh_key_keypair.private_key_pem}"
    }
  }
  
  provisioner "remote-exec" {
    inline = [
      "set -e",
      "export LB_HOSTNAME=${ibm_is_lb.lb.hostname}",
      "export DB_USER=${local.db_user}",
      "export DB_PASSWORD=${local.db_password}",
      "export DB_NAME=${local.db_name}",
      "export DB_HOST=${ibm_is_instance.vm3.primary_network_interface.0.primary_ipv4_address}",
      "export SLAVE_DB_HOST=${ibm_is_instance.vm4.primary_network_interface.0.primary_ipv4_address}",
      "export DB_PASSWORD=${local.db_password}",
      "export SCRIPT_PATH=/tmp/scripts/",
      "chmod -R u+x /tmp/scripts*/*",
      "/tmp/scripts/install_app.sh",
      "exit 0",
    ]
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = "${ibm_is_floating_ip.fip2.address}"
      private_key = "${tls_private_key.ssh_key_keypair.private_key_pem}"
    }
  }
}

resource "null_resource" "provisioner3" {

  triggers = {
    vmid = "${ibm_is_floating_ip.fip3.address}"
  }

  provisioner "file" {
    source =  "scripts"   
    destination = "/tmp"
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = "${ibm_is_floating_ip.fip3.address}"
      private_key = "${tls_private_key.ssh_key_keypair.private_key_pem}"
    }
  }
  
  provisioner "remote-exec" {
    inline = [
      "set -e",
      "export DB_PASSWORD=${local.db_password}",
      "export DB_USER=${local.db_user}",
      "export DB_NAME=${local.db_name}",
      "export SCRIPT_PATH=/tmp/scripts/",
      "chmod -R u+x /tmp/scripts*/*",
      "/tmp/scripts/install_db.sh /tmp/scripts/install_common.sh /tmp/scripts/db/install_common.sh /tmp/scripts/db/setup_db.sh  /tmp/scripts/db/setup_master.sh",
      "exit 0",
    ]
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = "${ibm_is_floating_ip.fip3.address}"
      private_key = "${tls_private_key.ssh_key_keypair.private_key_pem}"
    }
  }
}

resource "null_resource" "provisioner4" {

  triggers = {
    vmid = "${ibm_is_floating_ip.fip4.address}"
  }

  provisioner "file" {
    source =  "scripts"   
    destination = "/tmp"
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = "${ibm_is_floating_ip.fip4.address}"
      private_key = "${tls_private_key.ssh_key_keypair.private_key_pem}"
    }
  }
  
  provisioner "remote-exec" {
    inline = [
      "set -e",
      "export DB_PASSWORD=${local.db_password}",
      "export DB_USER=${local.db_user}",
      "export DB_NAME=${local.db_name}",
      "export MASTER_HOST=${ibm_is_instance.vm3.primary_network_interface.0.primary_ipv4_address}",
      "export MASTER_USER=${local.db_user}",
      "export MASTER_PASSWORD=${local.db_password}",
      "export MASTER_LOG_FILE='mysql-bin.000001'",
      "export MASTER_LOG_POS=6941",
      "export SCRIPT_PATH=/tmp/scripts/",
      "chmod -R u+x /tmp/scripts*/*",
      "/tmp/scripts/install_db.sh /tmp/scripts/install_common.sh /tmp/scripts/db/install_common.sh /tmp/scripts/db/setup_db.sh  /tmp/scripts/db/setup_slave.sh",
      "exit 0",
    ]
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = "${ibm_is_floating_ip.fip4.address}"
      private_key = "${tls_private_key.ssh_key_keypair.private_key_pem}"
    }
  }
}

resource "ibm_is_lb" "lb" {
  name    = "loadbalancer1"
  subnets = ["${ibm_is_subnet.subnet.0.id}"]
}

resource "ibm_is_lb_pool" "lb_pool" {
  name           = "lamppool"
  lb             = "${ibm_is_lb.lb.id}"
  algorithm      = "round_robin"
  protocol       = "http"
  health_delay   = 20
  health_retries = 2
  health_timeout = 2
  health_type    = "http"
  health_monitor_url = "/"
}

resource "ibm_is_lb_pool_member" "app_serv_1_lb_member" {
  lb             = "${ibm_is_lb.lb.id}"
  pool           = "${ibm_is_lb_pool.lb_pool.id}"
  port           = 80
  target_address = "${ibm_is_instance.vm1.primary_network_interface.0.primary_ipv4_address}"
}

resource "ibm_is_lb_pool_member" "app_serv_2_lb_member" {
  lb             = "${ibm_is_lb.lb.id}"
  pool           = "${ibm_is_lb_pool.lb_pool.id}"
  port           = 80
  target_address = "${ibm_is_instance.vm2.primary_network_interface.0.primary_ipv4_address}"
}

resource "ibm_is_lb_listener" "lb_listener" {
  lb  = "${ibm_is_lb.lb.id}"
  port     = "80"
  protocol = "http"
  default_pool = "${ibm_is_lb_pool.lb_pool.id}"
}


