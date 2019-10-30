####################################################
##################### VARIABLES ####################
####################################################

#PowerVC - vm4 configuration
#----------------------------------

variable "vm4_image_name" {
  description = "Image Name for PowerVC instance"
}

variable "vm4_first_ip" {
  description = "vm4 First IP to be used"
}

variable "vm4_name" {
  description = "Name of the Virtual Machine"
}

variable "vm4_number" {
  description = "Number of vm4s"
}

variable "vm4_memory" {
  description = "VM Memory GB"
}

variable "vm4_cpu" {
  description = "VM CPU"
}

variable "vm4_power_state" {
  description = "VM Power State (active|shutoff)"
  default     = "active"
}

variable "vm4_remote_restart" {
  description = "remote restart state (true|false)"
  default     = "false"
}

variable "vm4_vcpu_ratio" {
  description = "virtual CPU ratio 1:X" #VCPU RATIO 1:5 1 vcpu = 0.2 pcpu (cores)
  default     = "5"
}

####################################################
################## LOCAL VARIABLEs #################
####################################################
locals {
  ##General variables:  
  #------------------------------------------------------------------------------------------------#

  ##Flavor configuration
  #------------------------------------------------------------------------------------------------#
  #vm4_flavor_name = "${var.vm1_name}-flavor-${uuid()}"
  vm4_flavor_name = "${var.vm4_name}-flavor"

  #VCPU RATIO 1:5 1 vcpu = 0.2 pcpu (cores)
  vm4_vcpu_ratio = "${var.vm4_vcpu_ratio}"

  #VM MIN_MEMORY GB (vm requiere min/desired/max)
  vm4_min_memory = 2

  #VM MAX_MEMORY GB (vm requiere min/desired/max)
  vm4_max_memory = "64"

  #CONDITION ? TRUEVAL : FALSEVAL
  #---Calculate value for max Memory
  val_vm4_max_memory = "${var.vm4_memory < local.vm4_max_memory ? local.vm4_max_memory : var.vm4_memory * 2}"

  #VM MIN CPU (vm requiere min/desired/max)
  vm4_min_cpu = 1

  #VM MAX_CPU
  vm4_max_cpu = 16

  #----Calculate value for max CPU
  val_vm4_max_cpu = "${var.vm4_cpu < local.vm4_max_cpu ? local.vm4_max_cpu : var.vm4_cpu * 2}"


  #IP - cluster:
  vm4_ip_octets = split(".", "${var.vm4_first_ip}")


}

####################################################
################### DATASOURCES ####################
####################################################
data "openstack_images_image_v2" "vm4-image-name" {
  name        = "${var.vm4_image_name}"
  most_recent = true
}

####################################################
#################### RESOURCES #####################
####################################################

###################################################################################
### Create PowerVC custom flavor - Shared CPU :
###################################################################################
resource "openstack_compute_flavor_v2" "vm4-flavor" {
  count = "${var.vm4_number > 0 ? 1 : 0}"
  name  = "${local.vm4_flavor_name}"
  ram   = "${var.vm4_memory * 1024}"
  vcpus = "${var.vm4_cpu}"
  disk  = "0"

  extra_specs = {
    "powervm:processor_compatibility" = "default"
    "powervm:dedicated_proc"          = "false"
    "powervm:availability_priority"   = "127"
    "powervm:uncapped"                = "true"
    "powervm:shared_weight"           = "128"
    "powervm:enable_lpar_metric"      = "true"
    "powervm:srr_capability"          = "${var.vm4_remote_restart}"
    "powervm:min_mem"                 = "${local.vm4_min_memory * 1024}"
    "powervm:max_mem"                 = "${local.val_vm4_max_memory * 1024}"
    "powervm:min_vcpu"                = "${local.vm4_min_cpu}"
    "powervm:max_vcpu"                = "${local.val_vm4_max_cpu}"
    "powervm:min_proc_units"          = "${local.vm4_min_cpu / local.vm4_vcpu_ratio}"
    "powervm:proc_units"              = "${var.vm4_cpu / local.vm4_vcpu_ratio}"
    "powervm:max_proc_units"          = "${local.vm4_max_cpu / local.vm4_vcpu_ratio}"
  }
}

###################################################################################
#### Create PowerVC instance:
###################################################################################
resource "openstack_compute_instance_v2" "vm4" {

  depends_on = [
    "openstack_compute_flavor_v2.vm4-flavor",
    "openstack_compute_instance_v2.vm1",
    "openstack_compute_instance_v2.vm2",
    "openstack_compute_instance_v2.vm3",
  ]

  count = "${var.vm4_number}"


  name              = "${format("${var.vm4_name}-%02d", count.index + 1)}"
  image_id          = "${data.openstack_images_image_v2.vm4-image-name.id}"
  power_state       = "${var.vm4_power_state}"
  availability_zone = element("${data.openstack_compute_availability_zones_v2.AZ.names}", count.index)
  flavor_id         = "${openstack_compute_flavor_v2.vm4-flavor[0].id}"
  force_delete      = "true"

  #Network configuration ADMIN(ent0)
  network {
    name = "${var.net1_name}"
    #uuid = "${openstack_networking_network_v2.net1.id}"
    #fixed_ip_v4 = "${var.vm4_first_ip}${format("%1d", count.index + 1)}"
    fixed_ip_v4 = "${local.vm4_ip_octets[0]}.${local.vm4_ip_octets[1]}.${local.vm4_ip_octets[2]}.${local.vm4_ip_octets[3] + count.index}"
  }

  #Cloud-Init user-data
  user_data = <<-EOF
#!/bin/sh

cp /etc/resolv.conf /etc/resolv.conf.orig.$(date +%Y%m%d)
cat >/etc/resolv.conf<<"EOF_/etc/resolv.conf"
search ${var.dns_domain}
domain ${var.dns_domain}
nameserver ${var.dns1}
EOF_/etc/resolv.conf
chown root:root /etc/resolv.conf
chmod 644 /etc/resolv.conf

echo "PEERDNS=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "DNS1=${var.dns1}" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "SEARCH=${var.dns_domain}" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "DOMAIN=${var.dns_domain}" >> /etc/sysconfig/network-scripts/ifcfg-eth0
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
resource "null_resource" "vm4_post_install_config" {

  depends_on = ["openstack_compute_instance_v2.vm4"]

  count = "${var.vm4_number}"

  # Specify the ssh connection
  connection {
    type     = "ssh"
    user     = "${var.ssh_user}"
    password = "${var.ssh_user_password}"
    host     = "${openstack_compute_instance_v2.vm4[count.index].network.0.fixed_ip_v4}"
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

}
