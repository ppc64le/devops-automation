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
output "ip_address" {
  value = "${ibm_is_floating_ip.fip1.address}"
}

output "ssh_rule" {
  value = "${ibm_is_security_group_rule.sg1-tcp-rule.0.id}"
}

output "instance_ssh_private" {
  value = "${tls_private_key.ssh_key_keypair.private_key_pem}"
}
