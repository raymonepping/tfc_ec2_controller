##############################################################################
# Terraform and provider requirements
##############################################################################

terraform {
  # Tested with 1.14, but anything from 1.6 upwards is fine for this demo
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

##############################################################################
# AWS provider
#
# The region is driven by var.region from terraform.tfvars.
# All child modules inherit this provider configuration.
##############################################################################

provider "aws" {
  region = var.region

  # Global default tags that are merged with module-level tags
  default_tags {
    tags = {
      ManagedBy = "HCP Terraform"
    }
  }
}
