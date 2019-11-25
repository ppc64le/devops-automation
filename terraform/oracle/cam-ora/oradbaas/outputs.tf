#####################################################################
##
##      Created 11/18/19 by admin. for oradbaas
##
#####################################################################

output "dbserver_ipaddr" {
  value = "${format("%s",join(",", openstack_compute_instance_v2.dbserver.*.network.0.fixed_ip_v4))}"
}

output "dbserver_vm_name" {
  value = "${format("%s",join(",", openstack_compute_instance_v2.dbserver.*.name))}"
  description = "VM name in PowerVC"
}

output "dbserver_ts" {
  value = "${format("${local.local_dbserver_ts}")}"
}
