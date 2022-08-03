## Template to be used by the IBM Provider for Power Systems

# Only needed if you need to execute a script within the VM
# at initial VM deployment time
#
# resource "local_file" "vm_private_key" {
#     content_base64    = var.vm_private_key_base64
#     filename          = "tmp/id_rsa"
# }

data "ibm_pi_network" "power_networks" {
    count                = length(var.networks)
    pi_network_name      = var.networks[count.index]
    pi_cloud_instance_id = var.power_instance_id
}

data "ibm_pi_image" "power_images" {
    pi_image_name        = var.image_name
    pi_cloud_instance_id = var.power_instance_id
}

resource "ibm_pi_instance" "pvminstance" {
    pi_memory               = var.memory
    pi_processors           = var.processors
    pi_instance_name        = var.vm_name
    pi_proc_type            = var.proc_type
    pi_storage_type         = var.storage_type
    pi_migratable           = var.migratable
    pi_image_id             = data.ibm_pi_image.power_images.id
    pi_volume_ids           = []
    pi_network { network_id = data.ibm_pi_network.power_networks.0.id }
    pi_key_pair_name        = var.ssh_key_name
    pi_sys_type             = var.system_type
    pi_replication_policy   = var.replication_policy
    pi_replication_scheme   = var.replication_scheme
    pi_replicants           = var.replicants
    pi_cloud_instance_id    = var.power_instance_id

#    Only needed if you need to execute a script within the VM
#    at initial VM deployment time
#
#    provisioner "remote-exec" {
#        scripts = [
#            "scripts/wait_for_vm.sh",
#            "scripts/bootstrap-aix.sh",
#        ]
#
#        connection {
#            type        = "ssh"
#            host        = "${lookup(ibm_pi_instance.pvminstance.pi_network[0], "external_ip")}"
#            timeout     = "15m"
#            user        = "root"
#            private_key = "${file("${local_file.vm_private_key.filename}")}"
#        }
#    }
}
