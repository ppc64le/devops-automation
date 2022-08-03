terraform {
    required_version = ">=1.0.0, <2.0"
    required_providers {
        ibm = {
            source  = "IBM-Cloud/ibm"
            version = ">= 1.44.0"
        }
    }
}

provider "ibm" {
    ibmcloud_api_key = var.ibmcloud_api_key
    region           = var.ibmcloud_region
    zone             = var.ibmcloud_zone
}
