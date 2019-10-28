output "status" {
    value = "${ibm_pi_instance.pvminstance.pi_instance_status}"
}

output "min_proc" {
    value = "${ibm_pi_instance.pvminstance.pi_minproc}"
}

output "health_status" {
    value = "${ibm_pi_instance.pvminstance.pi_health_status}"
}

output "ip_address" {
    value = "${ibm_pi_instance.pvminstance.addresses}"
}

output "progress" {
    value = "${ibm_pi_instance.pvminstance.pi_progress}"
}
