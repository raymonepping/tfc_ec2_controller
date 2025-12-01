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
  # Only try to look up a VPC by name when:
  # - you did not pass a vpc_id
  # - you did pass a vpc_name
  # - and you are NOT using the managed VPC module
  count = var.vpc_id == "" && var.vpc_name != "" && !var.enable_vpc ? 1 : 0

  tags = {
    Name = var.vpc_name
  }
}

##############################################################################
# Subnet lookup by intent (Tier tag)
##############################################################################

data "aws_subnets" "selected_by_tier" {
  # Only try to discover subnets when:
  # - we have a resolved base_vpc_id
  # - we are NOT using the managed VPC module
  count = local.base_vpc_id != null && !var.enable_vpc ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [local.base_vpc_id]
  }

  filter {
    name   = "tag:${var.subnet_tier_tag_key}"
    values = [var.subnet_tier_tag_value]
  }
}

##############################################################################
# Route53 hosted zone lookup
#
# When route53_zone_id is empty and effective_domain is set, we resolve the
# hosted zone by its DNS name.
##############################################################################

data "aws_route53_zone" "selected" {
  count = var.route53_zone_id == "" && local.effective_domain != "" ? 1 : 0

  name         = local.effective_domain
  private_zone = false
}
