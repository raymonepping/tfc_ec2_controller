##############################################################################
# Data sources
#
# This file keeps all shared lookups together.
# For this demo:
#   - We resolve a RHEL 10 AMI from the Red Hat publisher account
#   - We pin architecture and root device characteristics so it matches
#     the lifecycle precondition in the compute module
##############################################################################

##############################################################################
# AMI lookup is handled by the ami module.
# It uses official Red Hat images and respects architecture.
##############################################################################

##############################################################################
# VPC lookup by intent
##############################################################################

data "aws_vpc" "selected_by_name" {
  count = var.vpc_id == "" && var.vpc_name != "" ? 1 : 0

  tags = {
    Name = var.vpc_name
  }
}

##############################################################################
# Subnet lookup by intent (Tier tag)
##############################################################################

data "aws_subnets" "selected_by_tier" {
  count = length(var.subnet_ids) == 0 ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [local.base_vpc_id]
  }

  filter {
    name   = "tag:${var.subnet_tier_tag_key}"
    values = [var.subnet_tier_tag_value]
  }
}
