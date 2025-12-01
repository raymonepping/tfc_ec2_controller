##############################################################################
# Root composition module
#
# This file wires together the building blocks for the demo:
#   - ami        – dynamic RHEL 10 AMI lookup
#   - vpc        – optional managed VPC and public subnets
#   - tags       – central tagging logic
#   - network    – security group and ingress rules
#   - compute    – EC2 instances behind the ALB
#   - storage    – optional data EBS volumes for each instance
#   - alb        – Application Load Balancer that fronts the instances
#   - dns        – optional Route53 record pointing at the ALB
#
# All provider configuration lives in providers.tf
# Data sources such as the default RHEL 10 AMI live in data.tf
##############################################################################

module "ami" {
  source = "./modules/ami"

  os_type         = var.os_type
  architecture    = var.architecture
  ami_id_override = var.ami_id

  # Tagging resources inside the ami module
  tags = merge(
    module.tags.effective_tags,
    {
      Module        = "ami"
      ModuleVersion = local.module_versions.ami
    }
  )

}

##############################################################################
# Tag module – central place for tag strategy
#
# The tags module takes high level inputs
#   environment, cost_center, application, owner, extra_tags
# and returns a single merged map in effective_tags.
#
# All other modules use these tags so that the tagging model stays consistent.
##############################################################################
module "tags" {
  source      = "./modules/tags"
  environment = local.effective_environment
  cost_center = local.effective_cost_center
  application = local.effective_application
  owner       = local.effective_owner
  extra_tags = merge(
    var.extra_tags,
    {
      StackVersion  = local.stack_version
      ModulesSchema = "v1"
    }
  )
}

##############################################################################
# VPC module – optional managed VPC and public subnets
#
# When enable_vpc = true, this module:
#   - Creates a VPC and public subnets
#   - Exposes vpc_id and public_subnet_ids
#
# When enable_vpc = false, the stack uses the existing vpc_id and subnet_ids
# that you pass in via variables.
##############################################################################
module "vpc" {
  source = "./modules/vpc"
  count  = var.enable_stack && var.enable_vpc ? 1 : 0

  vpc_cidr_block      = var.vpc_cidr_block
  azs                 = var.vpc_azs
  public_subnet_cidrs = var.public_subnet_cidrs

  # Tagging resources inside the vpc module
  tags = merge(
    module.tags.effective_tags,
    {
      Module        = "vpc"
      ModuleVersion = local.module_versions.vpc
    }
  )

}

##############################################################################
# Storage module – optional per instance data volumes
#
# This module:
#   - Creates one EBS volume per EC2 instance when create_data_volumes is true
#   - Attaches each volume to the matching instance id
#   - Uses the instance AZs from the compute module so volumes are AZ correct
#
# Note:
#   Although the storage module is declared before the compute module,
#   Terraform uses references (module.compute.*) to build the dependency graph.
#   It will always create the EC2 instances before attaching volumes.
##############################################################################
module "storage" {
  source = "./modules/storage"
  count  = var.enable_stack && var.enable_storage ? 1 : 0

  create_data_volumes = var.data_volume_enabled

  instance_ids       = module.compute.instance_ids
  availability_zones = module.compute.instance_azs
  volume_name_prefix = "${local.effective_instance_name_prefix}-data"
  volume_size        = var.data_volume_size
  volume_type        = var.data_volume_type
  device_name        = var.data_volume_device_name

  # EBS encryption flags
  encrypted  = var.data_volume_encrypted
  kms_key_id = var.data_volume_kms_key_id

  # Tagging resources inside the storage module
  tags = merge(
    module.tags.effective_tags,
    {
      Module        = "storage"
      ModuleVersion = local.module_versions.storage
    }
  )

}

##############################################################################
# Network module – security group and ingress rules
#
# This module:
#   - Reuses the existing VPC
#   - Creates a security group for the EC2 instances
#   - Manages SSH and HTTP rules using the rules only pattern
##############################################################################
module "network" {
  source = "./modules/network"

  vpc_id              = local.effective_vpc_id
  security_group_name = var.security_group_name
  ssh_ingress_cidr    = var.ssh_ingress_cidr
  http_ingress_cidr   = var.http_ingress_cidr

  # Tagging resources inside the network module
  tags = merge(
    module.tags.effective_tags,
    {
      Module        = "network"
      ModuleVersion = local.module_versions.network
    }
  )

}

##############################################################################
# Compute module – EC2 instances behind the ALB
#
# This module:
#   - Launches instance_count EC2 instances in the effective subnet
#   - Attaches the security group from the network module
#   - Uses the effective_ami_id local for AMI selection
#   - Configures root volume size and type
#   - Enforces a lifecycle precondition on architecture
#   - Enforces a lifecycle postcondition that each instance has a public IP
#
# Extra data volumes are handled by the storage module so that the instance
# definition stays clean and reusable.
##############################################################################
module "compute" {
  source = "./modules/compute"

  instance_count       = var.instance_count
  ami_id               = local.effective_ami_id
  instance_type        = local.effective_instance_type
  instance_name_prefix = local.effective_instance_name_prefix
  subnet_id            = local.effective_subnet_id
  security_group_id    = module.network.security_group_id
  ssh_key_name         = local.effective_ssh_key_name

  # Tagging resources inside the compute module
  tags = merge(
    module.tags.effective_tags,
    {
      Module        = "compute"
      ModuleVersion = local.module_versions.compute
    }
  )

  # Storage configuration
  root_volume_size      = var.root_volume_size
  root_volume_type      = var.root_volume_type
  root_volume_encrypted = var.root_volume_encrypted

  # Lifecycle guardrail input
  architecture = var.architecture

  # Optional IAM instance profile coming from the IAM module
  iam_instance_profile = var.enable_stack && var.enable_iam && length(module.iam) > 0 ? module.iam[0].instance_profile_name : null

  # Toggle to enable/disable the compute module
  enable_instances = var.enable_stack && var.enable_instances
}

module "iam" {
  source = "./modules/iam"
  count  = var.enable_stack && var.enable_iam ? 1 : 0

  role_name             = var.iam_role_name
  instance_profile_name = var.iam_instance_profile_name
  policy_arns           = var.iam_policy_arns

  # Tagging resources inside the iam module
  tags = merge(
    module.tags.effective_tags,
    {
      Module        = "iam"
      ModuleVersion = local.module_versions.iam
    }
  )

}

##############################################################################
# ALB module – Application Load Balancer in front of the instances
#
# This module:
#   - Creates an internet facing ALB in the given VPC and subnets
#   - Creates a target group and attaches the EC2 instances
#   - Creates an HTTP listener on port 80
#   - Reuses the same tag strategy via module.tags.effective_tags
##############################################################################
module "alb" {
  source = "./modules/alb"
  count  = var.enable_stack && var.enable_alb ? 1 : 0

  vpc_id       = local.effective_vpc_id
  subnet_ids   = local.effective_subnet_ids
  instance_ids = module.compute.instance_ids

  alb_name      = "ec2-demo-alb"
  listener_port = 80
  target_port   = 80

  # Tagging resources inside the iam module
  tags = merge(
    module.tags.effective_tags,
    {
      Module        = "alb"
      ModuleVersion = local.module_versions.alb
    }
  )

}

##############################################################################
# DNS module – optional Route53 record for the ALB
#
# This module:
#   - Creates an alias A record in a given hosted zone
#   - Points the record at the ALB DNS name and zone id
#   - Is controlled by create_dns_record so it is safe in labs
#
# Example output:
#   ec2-demo.raymon-epping.sbx.hashidemos.io -> ALB
##############################################################################
module "dns" {
  source = "./modules/dns"
  count  = var.enable_stack && var.enable_alb && var.enable_dns ? 1 : 0

  create_record = var.enable_dns
  zone_id       = var.route53_zone_id
  record_name   = var.route53_record_name

  alb_dns_name = module.alb[0].alb_dns_name
  alb_zone_id  = module.alb[0].alb_zone_id

  # Tagging resources inside the dns module
  tags = merge(
    module.tags.effective_tags,
    {
      Module        = "dns"
      ModuleVersion = local.module_versions.dns
    }
  )

}