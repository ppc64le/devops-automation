################################################################
# Module to deploy a VM with specified applications installed
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Licensed Materials - Property of IBM
#
# ©Copyright IBM Corp. 2020
#
################################################################

provider "ibm" {
    version          = ">= 0.20.0"
    ibmcloud_api_key = "${var.ibmcloud_api_key}"
    generation       = "2"
    region           = "${var.vpc_region}"
}

