module "network" {
  source = "./modules/network"

  vpc_id              = var.vpc_id
  subnet_id           = var.subnet_id
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
  ssh_key_name         = var.ssh_key_name

  subnet_id         = module.network.subnet_id_effective
  security_group_id = module.network.security_group_id

  ami_id = local.effective_ami_id

  tags = var.tags
}

module "alb" {
  source = "./modules/alb"

  vpc_id        = module.network.vpc_id
  subnet_ids    = module.network.subnet_ids
  instance_ids  = module.compute.instance_ids
  alb_name      = "ec2-demo-alb"
  listener_port = 80
  target_port   = 80
  tags          = var.tags
}