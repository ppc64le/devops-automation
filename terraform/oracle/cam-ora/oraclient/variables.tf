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
##      Deploy LOP with Oracle client and Swingbench for oraclient
##
#####################################################################

variable "dbclient_name" {
  type = "string"
  description = "DB client name (VM) on PowerVC"
  default = "dbc"
}

variable "openstack_image_name_dbclient" {
  type = "string"
  description = "PowerVC image name"
}

variable "openstack_flavor_name_dbclient" {
  type = "string"
  description = "PowerVC Compute Template name"
}

variable "openstack_network_name" {
  type = "string"
  description = "PowerVC network name"
}

variable "dbserver_user_data" {
  type = "string"
  description = "Oracle DB name"
}

variable "dbserver_ipaddr" {
  type = "string"
  description = "DB server IP address"
}

variable "dbserver_ts" {
  type = "string"
  description = "Unique id to be appended to db client name"
}

