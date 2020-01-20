output "Access Ubuntu Apache2 Default Page" {
  value = "https://${ibm_is_floating_ip.fip1.address}/"
}

output "Access PHP Info by" {
  value = "https://${ibm_is_floating_ip.fip1.address}/info.php"
}

output "Validate MariaDB Connection by accessing" {
  value = "https://${ibm_is_floating_ip.fip1.address}/todo_list.php"
}

output "Instance SSH Private Key (for debug purposes)" {
  value = "\n${tls_private_key.ssh_key_keypair.private_key_pem}"
}
