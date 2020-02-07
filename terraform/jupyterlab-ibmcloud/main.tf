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
  vm_profile = "gp2-8x64x2"
}


module  "simple_instance" {
 source = "github.com/ppc64le/devops-automation/terraform/modules/simple_vm"
 basename  = "${var.basename}"
 vpc_region  = "${var.vpc_region}"
 vpc_zone  = "${var.vpc_zone}"
 ibmcloud_api_key  = "${var.ibmcloud_api_key}"
 vm_profile  = "${local.vm_profile}"
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
      "set -x",
      "export SSH_IP=${module.simple_instance.ip_address}",
      "chmod +x /tmp/scripts*/*",
      "/tmp/scripts/install_common.sh",
      "/tmp/scripts/install_cuda.sh",
      "/tmp/scripts/install_docker.sh",
      "/tmp/scripts/install_runtime.sh",
      "/tmp/scripts/setup_instance.sh",
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

