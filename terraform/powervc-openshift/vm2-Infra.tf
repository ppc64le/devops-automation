####################################################
##################### VARIABLES ####################
####################################################

#PowerVC - vm2 configuration
#----------------------------------
variable "vm2_storage_name" {
  description = "Storage Pool where to place the new VM"
}

variable "vm2_image_name" {
  description = "Image Name for PowerVC instance"
}

variable "vm2_first_ip" {
  description = "vm2 First IP to be used"
}

variable "vm2_name" {
  description = "Name of the Virtual Machine"
}

variable "vm2_number" {
  description = "Number of vm2s"
}

variable "vm2_memory" {
  description = "VM Memory GB"
}

variable "vm2_cpu" {
  description = "VM CPU"
}

variable "vm2_power_state" {
  description = "VM Power State (active|shutoff)"
  default     = "active"
}

variable "vm2_remote_restart" {
  description = "remote restart state (true|false)"
  default     = "false"
}

variable "vm2_vcpu_ratio" {
  description = "virtual CPU ratio 1:X" #VCPU RATIO 1:5 1 vcpu = 0.2 pcpu (cores)
  default     = "5"
}

variable "vm2_dockerdisk1" {
  description = "Disk size for Disk1(GB)"
}


####################################################
################## LOCAL VARIABLEs #################
####################################################
locals {
  ##General variables:  
  #------------------------------------------------------------------------------------------------#

  ##Flavor configuration
  #------------------------------------------------------------------------------------------------#
  #vm2_flavor_name = "${var.vm2_name}-flavor-${uuid()}"
  vm2_flavor_name = "${var.vm2_name}-flavor"

  #VCPU RATIO 1:5 1 vcpu = 0.2 pcpu (cores)
  vm2_vcpu_ratio = "${var.vm2_vcpu_ratio}"

  #VM MIN_MEMORY GB (vm requiere min/desired/max)
  vm2_min_memory = 2

  #VM MAX_MEMORY GB (vm requiere min/desired/max)
  vm2_max_memory = "64"

  #CONDITION ? TRUEVAL : FALSEVAL
  #---Calculate value for max Memory
  val_vm2_max_memory = "${var.vm2_memory < local.vm2_max_memory ? local.vm2_max_memory : var.vm2_memory * 2}"

  #VM MIN CPU (vm requiere min/desired/max)
  vm2_min_cpu = 1

  #VM MAX_CPU
  vm2_max_cpu = 16

  #----Calculate value for max CPU
  val_vm2_max_cpu = "${var.vm2_cpu < local.vm2_max_cpu ? local.vm2_max_cpu : var.vm2_cpu * 2}"

  #IP - cluster:
  vm2_ip_octets = split(".", "${var.vm2_first_ip}")

}

####################################################
################### DATASOURCES ####################
####################################################
data "openstack_images_image_v2" "vm2-image-name" {
  name        = "${var.vm2_image_name}"
  most_recent = true
}

####################################################
#################### RESOURCES #####################
####################################################

###################################################################################
### Create PowerVC Server Group - anti-affinity:
###################################################################################
resource "openstack_compute_servergroup_v2" "vm2-servergroup-affinity" {
  count    = "${var.vm2_number > 1 ? 1 : 0}"
  name     = "${var.vm2_name}-servergroup"
  policies = ["soft-anti-affinity"]
}

###################################################################################
### Create PowerVC custom flavor - Shared CPU :
###################################################################################
resource "openstack_compute_flavor_v2" "vm2-flavor" {
  count = "${var.vm2_number > 0 ? 1 : 0}"
  name  = "${local.vm2_flavor_name}"
  ram   = "${var.vm2_memory * 1024}"
  vcpus = "${var.vm2_cpu}"
  disk  = "0"

  extra_specs = {
    "powervm:processor_compatibility" = "default"
    "powervm:dedicated_proc"          = "false"
    "powervm:availability_priority"   = "127"
    "powervm:uncapped"                = "true"
    "powervm:shared_weight"           = "128"
    "powervm:enable_lpar_metric"      = "true"
    "powervm:srr_capability"          = "${var.vm2_remote_restart}"
    "powervm:min_mem"                 = "${local.vm2_min_memory * 1024}"
    "powervm:max_mem"                 = "${local.val_vm2_max_memory * 1024}"
    "powervm:min_vcpu"                = "${local.vm2_min_cpu}"
    "powervm:max_vcpu"                = "${local.val_vm2_max_cpu}"
    "powervm:min_proc_units"          = "${local.vm2_min_cpu / local.vm2_vcpu_ratio}"
    "powervm:proc_units"              = "${var.vm2_cpu / local.vm2_vcpu_ratio}"
    "powervm:max_proc_units"          = "${local.vm2_max_cpu / local.vm2_vcpu_ratio}"
  }
}

###################################################################################
#### Create PowerVC instance:
###################################################################################
resource "openstack_compute_instance_v2" "vm2" {

  count = "${var.vm2_number}"

  depends_on = [
    "openstack_compute_flavor_v2.vm2-flavor",
    "openstack_compute_instance_v2.vm1",
  ]

  name         = "${format("${var.vm2_name}-%02d", count.index + 1)}"
  image_id     = "${data.openstack_images_image_v2.vm2-image-name.id}"
  power_state  = "${var.vm2_power_state}"
  flavor_id    = "${openstack_compute_flavor_v2.vm2-flavor[0].id}"
  force_delete = "true"

  availability_zone = element("${data.openstack_compute_availability_zones_v2.AZ.names}", count.index)
  #Network configuration
  network {
    name = "${var.net1_name}"
    #uuid = "${openstack_networking_network_v2.net1.id}"
    fixed_ip_v4 = "${local.vm2_ip_octets[0]}.${local.vm2_ip_octets[1]}.${local.vm2_ip_octets[2]}.${local.vm2_ip_octets[3] + count.index}"
  }

  scheduler_hints {
    group = "${openstack_compute_servergroup_v2.vm2-servergroup-affinity[0].id}"
  }

  #Cloud-Init user-data
  user_data = <<-EOF
#!/bin/sh
cp /etc/resolv.conf /etc/resolv.conf.orig.$(date +%Y%m%d)
cat >/etc/resolv.conf<<"EOF_/etc/resolv.conf"
search ${var.dns_domain}
nameserver ${var.dns1}
EOF_/etc/resolv.conf
chown root:root /etc/resolv.conf
chmod 644 /etc/resolv.conf

echo "PEERDNS=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "DNS1=${var.dns1}" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "SEARCH=\"${var.dns_domain}\"" >> /etc/sysconfig/network-scripts/ifcfg-eth0
systemctl restart NetworkManager

/usr/sbin/rsct/install/bin/recfgct
/usr/sbin/rsct/bin/rmcctrl -A
/usr/sbin/rsct/bin/rmcctrl -p


EOF
  #sleep 3 minutes
  provisioner "local-exec" {
    command = "sleep 180"
  }

}

#####################################################################################
########Post Installation configuration
#####################################################################################
resource "null_resource" "vm2_post_install_config" {

  depends_on = ["openstack_compute_instance_v2.vm2"]

  count = "${var.vm2_number}"

  # Specify the ssh connection
  connection {
    type     = "ssh"
    user     = "${var.ssh_user}"
    password = "${var.ssh_user_password}"
    host     = "${openstack_compute_instance_v2.vm2[count.index].network.0.fixed_ip_v4}"
    timeout  = "15m"
  }

  ## Start of the modification of the multipath configuration

  #Configure multipath
  provisioner "file" {
    content = <<EOF
#!/bin/bash

LOGFILE="/var/log/multipath.log"
#Update password:
chage -d $(date +'%Y-%m-%d') -M 90 root >> $LOGFILE 2>&1 || { echo "---Passowrd Policy Update Failed ---" | tee -a $LOGFILE; exit 1; }

cat >/etc/multipath.conf <<"EOF_/etc/multipath.conf"
defaults {
    user_friendly_names                         yes
}
devices {
    device {
        vendor                          "IBM"
        product                         "2145"
        path_grouping_policy            group_by_prio
        prio                            "alua"
        path_checker                    "tur"
        path_selector                   "service-time 0"
        failback                        "immediate"

        rr_weight                       "priorities"
        no_path_retry                   "fail"
        rr_min_io_rq                    10
        dev_loss_tmo                    600
        fast_io_fail_tmo                5
    }
}
multipaths {
}
EOF_/etc/multipath.conf

echo "---start multipath configuration---" | tee -a $LOGFILE 2>&1
> /etc/multipath/wwids
> /etc/multipath/bindings
rescan-scsi-bus.sh -a  >/dev/null 2>&1
echo 'reconfigure' | multipathd -k >> $LOGFILE 2>&1 || { echo "---Multipath Configuration Failed ---" | tee -a $LOGFILE; exit 1; }
sleep 5
head -n -1 /etc/multipath.conf > /tmp/multipath.conf
DISK_NAME="SYSTEM_DISK_"
i=0
for line in $(cat /etc/multipath/bindings | grep -v ^# | sed 's/ /;/g' )
do
    ((i++))
    dev_name=$(echo $line | cut -d';' -f1 )
    wwpn=$(echo $line | cut -d';' -f2)
    echo "      multipath {" >>/tmp/multipath.conf
    echo "          wwid                $wwpn" >>/tmp/multipath.conf
    echo "          alias               $DISK_NAME$i" >>/tmp/multipath.conf
    echo "      }" >>/tmp/multipath.conf
done
echo "}" >>/tmp/multipath.conf
echo yes | mv /tmp/multipath.conf /etc/multipath.conf
> /etc/multipath/wwids
> /etc/multipath/bindings
echo 'reconfigure' | multipathd -k >> $LOGFILE 2>&1 || { echo "---Multipath Configuration Failed ---" | tee -a $LOGFILE; exit 1; }

echo "---finish multipath configuration---" | tee -a $LOGFILE 2>&1
EOF

    destination = "/tmp/multipath.sh"
  }
  # Execute the script remotely
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/multipath.sh; bash /tmp/multipath.sh",
    ]
  }

  ## End of the multipath configuration section


  ### Copy the user_public_key
  provisioner "file" {
    content     = <<EOF
#!/bin/sh

LOGFILE="/var/log/addkey.log"

user_public_key=$1

if [ ! -f $HOME/.ssh/authorized_keys ] ; then
        mkdir -p $HOME/.ssh
        touch $HOME/.ssh/authorized_keys        >> $LOGFILE 2>&1 || { echo "---Failed to create authorized_keys---" | tee -a $LOGFILE; exit 1; }
        chmod 400 $HOME/.ssh/authorized_keys    >> $LOGFILE 2>&1 || { echo "---Failed to change permission of authorized_keys---" | tee -a $LOGFILE; exit 1; }
fi

if [ "$user_public_key" != "" ] ; then
        echo "---start adding user_public_key---" | tee -a $LOGFILE 2>&1
        chmod 600 $HOME/.ssh/authorized_keys    >> $LOGFILE 2>&1 || { echo "---Failed to change permission of authorized_keys---" | tee -a $LOGFILE; exit 1; }
        if [[ ! $(grep "$user_public_key" $HOME/.ssh/authorized_keys) ]] ; then
                echo "$user_public_key"  | tee -a $HOME/.ssh/authorized_keys    >> $LOGFILE 2>&1 || { echo "---Failed to add user_public_key---" | tee -a $LOGFILE; exit 1; }
        fi
        chmod 400 $HOME/.ssh/authorized_keys    >> $LOGFILE 2>&1 || { echo "---Failed to change permission of authorized_keys---" | tee -a $LOGFILE; exit 1; }
        echo "---finish adding user_public_key---" | tee -a $LOGFILE 2>&1
fi
EOF
    destination = "/tmp/addkey.sh"
  }
  # Execute the script remotely
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/addkey.sh; bash /tmp/addkey.sh \"${var.user_public_key}\"",
    ]
  }
  ### End of user_public_key copy

  ## Create createPVs.sh script
  provisioner "file" {
    content = <<EOF
#!/bin/bash

VGNAME=$1

LOGFILE="/var/log/datavg_$VGNAME.log"

echo "---Scanning the newly connected SCSI LUNS--- " | tee -a $LOGFILE 2>&1
> /etc/multipath/wwids
> /etc/multipath/bindings
rescan-scsi-bus.sh -a  >/dev/null 2>&1
sleep 30
rescan-scsi-bus.sh -a  >/dev/null 2>&1
echo 'reconfigure' | multipathd -k >> $LOGFILE 2>&1 || { echo "---Multipath Reconfiguration Failed ---" | tee -a $LOGFILE; exit 1; }
sleep 5
head -n -1 /etc/multipath.conf > /tmp/multipath.conf
DISK_NAME="$(echo $VGNAME | awk '{print toupper($0)}')_DISK_"
i=0
PV_LIST=""
for line in $(cat /etc/multipath/bindings | grep -v ^# | sed 's/ /;/g' )
do
    ((i++))
    dev_name=$(echo $line | cut -d';' -f1 )
    wwpn=$(echo $line | cut -d';' -f2)
    PV_LIST="$PV_LIST /dev/mapper/$DISK_NAME$i"
    echo "      multipath {" >>/tmp/multipath.conf
    echo "          wwid                $wwpn" >>/tmp/multipath.conf
    echo "          alias               $DISK_NAME$i" >>/tmp/multipath.conf
    echo "      }" >>/tmp/multipath.conf
done
echo "}" >>/tmp/multipath.conf
echo yes | mv /tmp/multipath.conf /etc/multipath.conf
> /etc/multipath/wwids
> /etc/multipath/bindings
echo 'reconfigure' | multipathd -k >> $LOGFILE 2>&1 || { echo "---Multipath Reconfiguration Failed ---" | tee -a $LOGFILE; exit 1; }
sleep 5

#echo "---Created the Physical Volumes---" | tee -a $LOGFILE 2>&1
#for PV in $PV_LIST
#do
#    pvcreate --dataalignment 4M $PV
#    PVCREATE=$?
#    if [ $PVCREATE -eq 0 ] ; then
#        echo "---Created the Physical Volume $PV---" | tee -a $LOGFILE 2>&1
#    else
#        echo "---Failed to create the Physical Volume $PV ---" | tee -a $LOGFILE; exit 1;
#    fi
#done

EOF

    destination = "/tmp/createPVs.sh"
  }
  # Execute the script remotely
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/createPVs.sh",
    ]
  }
  ## END DATA VG volumes
}

#####################################################################################
########Create dockerdisk1:
#####################################################################################
#Create Volume dockerdisk1:
resource "openstack_blockstorage_volume_v3" "vm2_dockerdisk1" {

  depends_on = ["null_resource.vm2_post_install_config"]

  count = "${var.vm2_dockerdisk1 > 0 ? "${var.vm2_number}" : 0}"
  #count                = "${var.vm2_number}"
  description          = "${format("${var.vm2_name}-%02d Docker Disk1", count.index + 1)}"
  name                 = "${format("${var.vm2_name}-%02d-docker-disk-1", count.index + 1)}"
  size                 = "${var.vm2_dockerdisk1}"
  enable_online_resize = "true"
  volume_type          = "${var.vm2_storage_name}"
}

#Attach Volume dockerdisk1
resource "openstack_compute_volume_attach_v2" "vm2_va_dockerdisk1" {

  depends_on = ["openstack_blockstorage_volume_v3.vm2_dockerdisk1"]

  count = "${var.vm2_dockerdisk1 > 0 ? "${var.vm2_number}" : 0}"
  #count       = "${var.vm2_number}"
  volume_id   = "${openstack_blockstorage_volume_v3.vm2_dockerdisk1[count.index].id}"
  instance_id = "${openstack_compute_instance_v2.vm2[count.index].id}"

  # Specify the ssh connection
  connection {
    type     = "ssh"
    user     = "${var.ssh_user}"
    password = "${var.ssh_user_password}"
    host     = "${openstack_compute_instance_v2.vm2[count.index].network.0.fixed_ip_v4}"
    timeout  = "5m"
  }

  # Create DATA VG
  provisioner "remote-exec" {
    inline = [
      "bash /tmp/createPVs.sh docker",
    ]
  }

  #sleep 2 minutes
  provisioner "local-exec" {
    command = "sleep 120"
  }
}