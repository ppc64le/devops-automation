variable "ibmcloud_api_key" {
    description = "Denotes the IBM Cloud API key to use"
}

#################################################
##               End of variables              ##
#################################################

provider "ibm" {
    version          = ">= 0.20.0"
    ibmcloud_api_key = "${var.ibmcloud_api_key}"
    generation       = "2"
    region           = "${var.vpc_region}"
}

