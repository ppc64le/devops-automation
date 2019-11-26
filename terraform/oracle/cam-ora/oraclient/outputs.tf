######################################################################
#  Copyright: IBM Corp., 2019
#
#  Written by: Stephen Poon, Ralf Schmidt-Dannert
#              IBM North America Systems Hardware
#              Power Technical Team, Oracle
#
#  Disclaimers:
#  This script is provided as-is to illustrate Oracle Database as a Service
#  with IBM PoverVC. This script is not part of any IBM product and has not
#  undergone extended testing of functionality or "fit for purpose" verification
#
#  Legal Stuff:
#
#  No Warranty
#  Subject to any statutory warranties which can not be excluded, IBM makes
#  no warranties or conditions either express or implied, including without
#  limitation, the warranty of non-infringement and the implied warranties
#  of merchantability and fitness for a particular purpose, regarding the
#  program or technical support, if any.
#
#  Limitation of Liability
#  Neither IBM nor its suppliers will be liable for any direct or indirect
#  damages, including without limitation, lost profits, lost savings, or any
#  incidental, special, or other economic consequential damages, even if IBM
#  is informed of their possibility. Some jurisdictions do not allow the
#  exclusion or limitation of incidental or consequential damages, so the
#  above exclusion or limitation may not apply to you.
#----------------------------------------------------------------------
#####################################################################
##
##      Deploy LOP with Oracle client and Swingbench for oraclient
##
#####################################################################

output "dbclient_ipaddr" {
  value = "${format("%s",join(",", openstack_compute_instance_v2.dbclient.*.network.0.fixed_ip_v4))}"
}

output "dbclient_vm_name" {
  value = "${format("%s",join(",", openstack_compute_instance_v2.dbclient.*.name))}"
  description = "dbclient VM name"
}

output "dbserver_connect" {
  value = "${format("Swingbench connect string: //%s/%s",var.dbserver_ipaddr, var.dbserver_user_data)}"
}
