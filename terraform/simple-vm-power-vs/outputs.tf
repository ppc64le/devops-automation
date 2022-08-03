output "status" {
    value = ibm_pi_instance.pvminstance.status
}

output "processors" {
    value = ibm_pi_instance.pvminstance.pi_processors
}

output "health_status" {
    value = ibm_pi_instance.pvminstance.health_status
}

output "network" {
    value = ibm_pi_instance.pvminstance.pi_network
}

output "progress" {
    value = ibm_pi_instance.pvminstance.pi_progress
}
