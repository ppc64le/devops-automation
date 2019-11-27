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

variable "dbserver_name" {
  type = "string"
  description = " db server VM name prefix. Oracle dbname and a timestamp will be appended in the PowerVC VM name."
}

variable "openstack_image_name" {
  type = "string"
  description = "PowerVC image name"
}

variable "openstack_flavor_name" {
  type = "string"
  description = "flavor name, or PowerVC compute template)"
}

variable "openstack_network_id" {
  type = "string"
  description = "Network id in PowerVC"
}

variable "dbserver_user_data" {
  type = "string"
  description = "Oracle DB name"
}

locals {
  local_dbserver_ts = "${replace(replace(replace(substr(timestamp(),2,17),"-",""),"T","_"),":","")}"
}
