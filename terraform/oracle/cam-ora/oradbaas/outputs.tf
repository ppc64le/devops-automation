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
