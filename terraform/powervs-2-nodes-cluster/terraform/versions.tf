terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = ">= 1.39.0"
    }
    null = {
      source = "hashicorp/null"
      version = ">= 3.2.1"
    }
  }
}
