output "Access Mean Web Page" {
  value = "http://${module.simple_instance.ip_address}/"
}

output "Instance SSH Private Key (for debug purposes)" {
  value = "\n${module.simple_instance.instance_ssh_private}"
}
