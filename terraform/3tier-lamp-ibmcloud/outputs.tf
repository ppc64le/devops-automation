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

output "rules" {
  value = "${ibm_is_security_group_rule.sg-tcp-rule.*.id}"
}

output "ssh_private_key" {
  value = "${tls_private_key.ssh_key_keypair.private_key_pem}"
}

output "fip_addresses1" {
  value = "${ibm_is_floating_ip.fip1.address}"
}

output "fip_addresses2" {
  value = "${ibm_is_floating_ip.fip2.address}"
}

output "fip_addresses3" {
  value = "${ibm_is_floating_ip.fip3.address}"
}

output "fip_addresses4" {
  value = "${ibm_is_floating_ip.fip4.address}"
}

output "site_http_address" {
  value = "http://${ibm_is_lb.lb.hostname}"
}

output "db_password" {
  value = "${local.db_password}"
}

output "app_password" {
  value = "${local.app_password}"
}

