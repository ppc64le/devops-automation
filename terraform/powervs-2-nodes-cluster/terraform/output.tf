data "ibm_pi_instance_ip" "node1_ip" {
  depends_on            = [ibm_pi_instance.node2]
  pi_instance_name      = ibm_pi_instance.node1.pi_instance_name
  pi_network_name       = data.ibm_pi_network.network.name
  pi_cloud_instance_id  = var.service_instance_id
}

data "ibm_pi_instance_ip" "node2_ip" {
  depends_on                = [ibm_pi_instance.node2]
  pi_instance_name          = ibm_pi_instance.node2.pi_instance_name
  pi_network_name           = data.ibm_pi_network.network.name
  pi_cloud_instance_id      = var.service_instance_id
}

output "node1_status" {
  value = "${ibm_pi_instance.node1.status}"
}
output "node1_minproc" {
  value = "${ibm_pi_instance.node1.min_processors}"
}
output "node1_healthstatus" {
  value = "${ibm_pi_instance.node1.health_status}"
}
output "node1_maxproc" {
  value = "${ibm_pi_instance.node1.max_processors}"
}
output "node1_maxmem" {
  value = "${ibm_pi_instance.node1.max_memory}"
}
output "node1_ip_address" {
  value      = data.ibm_pi_instance_ip.node1_ip.*.ip
}

output "node2_status" {
  value = "${ibm_pi_instance.node2.status}"
}
output "node2_minproc" {
  value = "${ibm_pi_instance.node2.min_processors}"
}
output "node2_healthstatus" {
  value = "${ibm_pi_instance.node2.health_status}"
}
output "node2_maxproc" {
  value = "${ibm_pi_instance.node2.max_processors}"
}
output "node2_maxmem" {
  value = "${ibm_pi_instance.node2.max_memory}"
}
output "node2_ip_address" {
  value      = data.ibm_pi_instance_ip.node2_ip.*.ip
}