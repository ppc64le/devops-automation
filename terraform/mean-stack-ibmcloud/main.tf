module  "simple_instance" {
 source = "github.com/jjalvare/simple_vm"
 basename  = "${var.basename}"
 vpc_region  = "${var.vpc_region}"
 ibmcloud_api_key  = "${var.ibmcloud_api_key}"
 vm_profile  = "${var.vm_profile}"
 boot_image_id  = "${var.boot_image_id}"
}

resource "null_resource" "provisioners" {

  triggers = {
    ssh_rule = "module.simple_instance.ssh_rule"
    ip_address = "module.simple_instance.ip_address"
  }

  provisioner "file" {
    source =  "scripts"   
    destination = "/tmp"
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = "${module.simple_instance.ip_address}"
      private_key = "${module.simple_instance.instance_ssh_private}"
    }
  }
  
  provisioner "remote-exec" {
    inline = [
      "set -e",
      "export VERSION=v12.14.1",
      "export DISTRO=linux-ppc64le",
      "chmod u+x /tmp/scripts*/*",
      "/tmp/scripts/wait_for_boot.sh",
      "/tmp/scripts/setup_mongodb.sh",
      "/tmp/scripts/install_nodejs.sh",
      "export PATH=/usr/local/lib/nodejs/node-$VERSION-$DISTRO/bin:$PATH", 
      "/tmp/scripts/setup_path.sh",
      "/tmp/scripts/setup_app.sh"
    ]
    connection {
      type = "ssh"
      user = "root"
      agent = false
      timeout = "5m"
      host = "${module.simple_instance.ip_address}"
      private_key = "${module.simple_instance.instance_ssh_private}"
    }
  }
}
