##############################################################################
# Root composition module
#
# This file wires together the building blocks for the demo:
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

##############################################################################
# Locals – helper values for AMI and subnet selection
##############################################################################
locals {
  effective_ami_id = (
    var.ami_id != null && var.ami_id != ""
  ) ? var.ami_id : data.aws_ami.rhel_10.id
}

locals {
  effective_subnet_id = (
    var.instance_subnet_id != null && var.instance_subnet_id != ""
  ) ? var.instance_subnet_id : var.subnet_ids[0]
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
  environment = var.environment
  cost_center = var.cost_center
  application = var.application
  owner       = var.owner
  extra_tags  = var.extra_tags
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

  create_data_volumes = var.data_volume_enabled

  instance_ids       = module.compute.instance_ids
  availability_zones = module.compute.instance_azs
  volume_size        = var.data_volume_size
  volume_type        = var.data_volume_type
  device_name        = var.data_volume_device_name

  volume_name_prefix = "${var.instance_name_prefix}-data"
  tags               = module.tags.effective_tags
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

  vpc_id              = var.vpc_id
  security_group_name = var.security_group_name
  ssh_ingress_cidr    = var.ssh_ingress_cidr
  http_ingress_cidr   = var.http_ingress_cidr
  tags                = module.tags.effective_tags
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

  instance_type        = var.instance_type
  instance_count       = var.instance_count
  instance_name_prefix = var.instance_name_prefix
  subnet_id            = local.effective_subnet_id
  security_group_id    = module.network.security_group_id
  ssh_key_name         = var.ssh_key_name
  ami_id               = local.effective_ami_id
  tags                 = module.tags.effective_tags

  # Storage configuration
  root_volume_size = var.root_volume_size
  root_volume_type = var.root_volume_type

  # Lifecycle guardrail input
  architecture = var.architecture
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

  vpc_id       = var.vpc_id
  subnet_ids   = var.subnet_ids
  instance_ids = module.compute.instance_ids

  alb_name      = "ec2-demo-alb"
  listener_port = 80
  target_port   = 80
  tags          = module.tags.effective_tags
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

  create_record = var.create_dns_record
  zone_id       = var.route53_zone_id
  record_name   = var.route53_record_name

  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id

}