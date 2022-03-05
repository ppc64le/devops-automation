####################################################
################### DATASOURCES ####################
####################################################
data "ibm_pi_network" "network" {
  pi_network_name           = var.network_name
  pi_cloud_instance_id      = var.service_instance_id
}

data "ibm_pi_image" "image" {
  pi_image_name             = var.image_name
  pi_cloud_instance_id      = var.service_instance_id
}

data "ibm_pi_key" "powerkey" {
  pi_cloud_instance_id      = var.service_instance_id
  pi_key_name               = var.ssh_key_pair_name
}

####################################################
#################### RESOURCES #####################
####################################################

###################################################################################
#### Create Cluster Placement Group:
###################################################################################
resource "ibm_pi_placement_group" "cluster_placement_group" {
  pi_placement_group_name   = "bs_cluster_pg"
  pi_placement_group_policy = "anti-affinity"
  pi_cloud_instance_id      =  var.service_instance_id
}

###################################################################################
#### Create CAA volumes:
###################################################################################
resource "ibm_pi_volume" "caa_disk_1"{
  pi_volume_size              = 10
  pi_volume_name              = "caa-disk1"
  pi_volume_type              = var.storage_type
  pi_volume_shareable         = true
  pi_cloud_instance_id        = var.service_instance_id
}

resource "ibm_pi_volume" "caa_disk_2"{
  pi_volume_size              = 10
  pi_affinity_policy          = "anti-affinity"
  pi_anti_affinity_volumes    = [ibm_pi_volume.caa_disk_1.volume_id]
  pi_volume_name              = "caa-disk2"
  pi_volume_type              = var.storage_type
  pi_volume_shareable         = true
  pi_cloud_instance_id        = var.service_instance_id
}



###################################################################################
#### Create PowerVS "node1" instance:
###################################################################################
resource "ibm_pi_instance" "node1" {
  pi_placement_group_id       = ibm_pi_placement_group.cluster_placement_group.placement_group_id
  pi_affinity_policy          = "affinity"
  pi_affinity_volume          = ibm_pi_volume.caa_disk_1.volume_id
  pi_instance_name            = var.node1_instance_name
  pi_memory                   = var.memory
  pi_processors               = var.processors
  pi_proc_type                = var.proc_type
  pi_image_id                 = data.ibm_pi_image.image.id
  pi_storage_type             = var.storage_type
  pi_key_pair_name            = var.ssh_key_pair_name
  pi_sys_type                 = var.system_type
  pi_cloud_instance_id        = var.service_instance_id
  pi_pin_policy               = var.pin_policy
  #pi_health_status            = "WARNING"
  pi_network {
    network_id                = data.ibm_pi_network.network.id
    ip_address                = var.node1_ip
  }
  pi_storage_pool_affinity     = false
  #pi_volume_ids               = [ibm_pi_volume.caa_disk_1.volume_id,ibm_pi_volume.caa_disk_2.volume_id]
  timeouts {
      create = "15m"
      delete = "15m"
  }
}



###################################################################################
#### Create PowerVS "node2" instance:
###################################################################################
resource "ibm_pi_instance" "node2" {
  depends_on                  = [ibm_pi_instance.node1]
  pi_placement_group_id       = ibm_pi_placement_group.cluster_placement_group.placement_group_id
  pi_affinity_policy          = "affinity"
  #pi_anti_affinity_instances  = [ibm_pi_instance.node1.instance_id]
  pi_affinity_volume          = ibm_pi_volume.caa_disk_2.volume_id
  pi_instance_name            = var.node2_instance_name
  pi_memory                   = var.memory
  pi_processors               = var.processors
  pi_proc_type                = var.proc_type
  pi_image_id                 = data.ibm_pi_image.image.id
  pi_storage_type             = var.storage_type
  pi_key_pair_name            = var.ssh_key_pair_name
  pi_sys_type                 = var.system_type
  pi_cloud_instance_id        = var.service_instance_id
  pi_pin_policy               = var.pin_policy
  #pi_health_status            = "WARNING"
  pi_network {
    network_id                = data.ibm_pi_network.network.id
    ip_address                = var.node2_ip
  }
  pi_storage_pool_affinity     = false
  #pi_volume_ids               = [ibm_pi_volume.caa_disk_1.volume_id,ibm_pi_volume.caa_disk_2.volume_id]
  timeouts {
      create = "15m"
      delete = "15m"
  }
}

###################################################################################
#### Create DATA volumes:
###################################################################################
resource "ibm_pi_volume" "data_disk_1"{
  pi_volume_size              = 50
  pi_affinity_policy          = "affinity"
  pi_affinity_volume          = ibm_pi_volume.caa_disk_1.volume_id
  pi_volume_name              = "data-disk1"
  pi_volume_type              = var.storage_type
  pi_volume_shareable         = true
  pi_cloud_instance_id        = var.service_instance_id
}

resource "ibm_pi_volume" "data_disk_2"{
  pi_volume_size              = 50
  pi_affinity_policy          = "affinity"
  pi_affinity_volume          = ibm_pi_volume.caa_disk_2.volume_id
  pi_volume_name              = "data-disk2"
  pi_volume_type              = var.storage_type
  pi_volume_shareable         = true
  pi_cloud_instance_id        = var.service_instance_id
}

###################################################################################
#### Attach CAA volumes:
###################################################################################
resource "ibm_pi_volume_attach" "caa_disk_1_node1"{
    pi_cloud_instance_id      = var.service_instance_id
    pi_volume_id              = ibm_pi_volume.caa_disk_1.volume_id
    pi_instance_id            = ibm_pi_instance.node1.instance_id
}

resource "ibm_pi_volume_attach" "caa_disk_2_node1"{
    pi_cloud_instance_id      = var.service_instance_id
    pi_volume_id              = ibm_pi_volume.caa_disk_2.volume_id
    pi_instance_id            = ibm_pi_instance.node1.instance_id
}

resource "ibm_pi_volume_attach" "caa_disk_1_node2"{
    depends_on                = [ibm_pi_volume_attach.caa_disk_1_node1]
    pi_cloud_instance_id      = var.service_instance_id
    pi_volume_id              = ibm_pi_volume.caa_disk_1.volume_id
    pi_instance_id            = ibm_pi_instance.node2.instance_id
}
resource "ibm_pi_volume_attach" "caa_disk_2_node2"{
    depends_on                = [ibm_pi_volume_attach.caa_disk_2_node1]
    pi_cloud_instance_id      = var.service_instance_id
    pi_volume_id              = ibm_pi_volume.caa_disk_2.volume_id
    pi_instance_id            = ibm_pi_instance.node2.instance_id
}

###################################################################################
#### Attach DATA volumes:
###################################################################################
resource "ibm_pi_volume_attach" "attach_data_disk_1_node1"{
    pi_cloud_instance_id      = var.service_instance_id
    pi_volume_id              = ibm_pi_volume.data_disk_1.volume_id
    pi_instance_id            = ibm_pi_instance.node1.instance_id
}

resource "ibm_pi_volume_attach" "attach_data_disk_2_node1"{
    pi_cloud_instance_id      = var.service_instance_id
    pi_volume_id              = ibm_pi_volume.data_disk_2.volume_id
    pi_instance_id            = ibm_pi_instance.node1.instance_id
}

resource "ibm_pi_volume_attach" "attach_data_disk_1_node2"{
    depends_on                = [ibm_pi_volume_attach.attach_data_disk_1_node1]
    pi_cloud_instance_id      = var.service_instance_id
    pi_volume_id              = ibm_pi_volume.data_disk_1.volume_id
    pi_instance_id            = ibm_pi_instance.node2.instance_id
}
resource "ibm_pi_volume_attach" "attach_data_disk_2_node2"{
    depends_on                = [ibm_pi_volume_attach.attach_data_disk_2_node1]
    pi_cloud_instance_id      = var.service_instance_id
    pi_volume_id              = ibm_pi_volume.data_disk_2.volume_id
    pi_instance_id            = ibm_pi_instance.node2.instance_id
}


###################################################################################
#### Run Ansible playbook for cluster installation and configuration:
###################################################################################
resource "null_resource" "ansible-playbook" {
  depends_on                = [ibm_pi_volume_attach.attach_data_disk_2_node2]
  count = var.ansible_enabled ? 1 : 0

  provisioner "local-exec" {
    command                   = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook cluster.yml"
    working_dir               = "../ansible"
  }
}

