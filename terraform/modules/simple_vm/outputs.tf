output "ip_address" {
  value = "${ibm_is_floating_ip.fip1.address}"
}

output "ssh_rule" {
  value = "${ibm_is_security_group_rule.sg1-tcp-rule.0.id}"
}

output "instance_ssh_private" {
  value = "${tls_private_key.ssh_key_keypair.private_key_pem}"
}
