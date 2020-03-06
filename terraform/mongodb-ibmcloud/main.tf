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

module  "simple_instance" {
 source = "github.com/ppc64le/devops-automation/terraform/modules/simple_vm"
 basename  = "${var.basename}"
 vpc_region  = "${var.vpc_region}"
 vpc_zone  = "${var.vpc_zone}"
 ibmcloud_api_key  = "${var.ibmcloud_api_key}"
 vm_profile  = "${var.vm_profile}"
 tcp_ports  = "22,80,443"
}

resource "random_password" "db_password" {
  length = 16
  special = true
  override_special = "!@_"
}

resource "random_password" "root_db_password" {
  length = 16
  special = true
  override_special = "!@_"
}

resource "random_password" "ui_password" {
  length = 16
  special = true
  override_special = "!@_"
}

resource "null_resource" "provisioners" {

  triggers = {
    ssh_rule = "module.simple_instance.ssh_rule"
    ip_address = "module.simple_instance.ip_address"
  }

  provisioner "file" {
    source =  "scripts"   
    destination = "/tmp"
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = "${module.simple_instance.ip_address}"
      private_key = "${module.simple_instance.instance_ssh_private}"
    }
  }
  
  provisioner "remote-exec" {
    inline = [
      "set -e",
      "export VERSION=v12.14.1",
      "export DISTRO=linux-ppc64le",
      "export API_DB_USERNAME=admin",
      "export API_DB_PASSWORD=${random_password.db_password.result}",
      "export API_ROOT_DB_USERNAME=root",
      "export API_ROOT_DB_PASSWORD=${random_password.root_db_password.result}",
      "export API_DB_PORT=27017",
      "export API_DB_NAME=db",
      "export API_UI_USERNAME=admin",
      "export API_UI_PASSWORD=${random_password.ui_password.result}",
      "export SCRIPT_PATH=/tmp/scripts/",
      "chmod u+x /tmp/scripts*/*",
      "export PATH=/usr/local/lib/nodejs/node-$VERSION-$DISTRO/bin:$PATH",
      "/tmp/scripts/install_app.sh"
    ]
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = "${module.simple_instance.ip_address}"
      private_key = "${module.simple_instance.instance_ssh_private}"
    }
  }
}
