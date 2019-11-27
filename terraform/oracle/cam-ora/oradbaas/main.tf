######################################################################
#  Copyright: IBM Corp., 2019
#
#  Written by: Stephen Poon, Ralf Schmidt-Dannert
#              IBM North America Systems Hardware
#              Power Technical Team, Oracle
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#  
#----------------------------------------------------------------------
#####################################################################
##
##      Deploy Oracle database as a service
##
#####################################################################

## REFERENCE {"openstack_network":{"type": "openstack_reference_network"}}

terraform {
  required_version = "> 0.8.0"
}

provider "openstack" {
  insecure    = true
  version = "~> 1.2"
}

resource "openstack_compute_instance_v2" "dbserver" {
  name      = "${format("${var.dbserver_name}-${var.dbserver_user_data}-${local.local_dbserver_ts}")}"
  image_name  = "${var.openstack_image_name}"
  flavor_name = "${var.openstack_flavor_name}"
  user_data = "${format("DBNAME=%s",var.dbserver_user_data)}"
  network {
    uuid = "${var.openstack_network_id}"
  }
}

