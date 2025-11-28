##############################################################################
# Root composition: network + compute + ALB
##############################################################################

locals {
  # If the caller supplied an AMI, use it, otherwise use the RHEL 10 AMI
  effective_ami_id = (
    var.ami_id != null && var.ami_id != ""
  ) ? var.ami_id : data.aws_ami.rhel_10.id

  # Architecture that we pass into the compute module for lifecycle checks
  effective_architecture = data.aws_ami.rhel_10.architecture
}

locals {
  effective_subnet_id = (
    var.instance_subnet_id != null && var.instance_subnet_id != ""
  ) ? var.instance_subnet_id : var.subnet_ids[0]
}

module "network" {
  source = "./modules/network"

  vpc_id              = var.vpc_id
  security_group_name = var.security_group_name
  ssh_ingress_cidr    = var.ssh_ingress_cidr
  http_ingress_cidr   = var.http_ingress_cidr
  tags                = var.tags
}

module "compute" {
  source = "./modules/compute"

  instance_type        = var.instance_type
  instance_count       = var.instance_count
  instance_name_prefix = var.instance_name_prefix
  subnet_id            = local.effective_subnet_id
  security_group_id    = module.network.security_group_id
  ssh_key_name         = var.ssh_key_name
  ami_id               = local.effective_ami_id
  tags                 = var.tags

  # Storage configuration
  root_volume_size        = var.root_volume_size
  root_volume_type        = var.root_volume_type
  data_volume_enabled     = var.data_volume_enabled
  data_volume_size        = var.data_volume_size
  data_volume_type        = var.data_volume_type
  data_volume_device_name = var.data_volume_device_name

  # Lifecycle guardrail input
  architecture = local.effective_architecture
}

module "alb" {
  source = "./modules/alb"

  vpc_id       = var.vpc_id
  subnet_ids   = var.subnet_ids
  instance_ids = module.compute.instance_ids

  alb_name      = "ec2-demo-alb"
  listener_port = 80
  target_port   = 80
  tags          = var.tags
}
