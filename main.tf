##############################################################################
# VPC and subnet discovery
##############################################################################

data "aws_vpc" "selected" {
  # If vpc_id is provided, select that VPC; otherwise select the default VPC
  default = var.vpc_id != null ? false : true
  id      = var.vpc_id != null ? var.vpc_id : null
}

data "aws_subnets" "defaults" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

##############################################################################
# RHEL 10 AMI discovery (Red Hat account 309956199498)
##############################################################################

data "aws_ami" "rhel_10" {
  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "name"
    values = [var.rhel_ami_name_prefix]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

##############################################################################
# Common locals
##############################################################################

locals {
  subnet_id_effective = var.subnet_id != null ? var.subnet_id : data.aws_subnets.defaults.ids[0]
}
