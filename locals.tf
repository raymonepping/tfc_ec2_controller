locals {
  stack_version = "1.0.0"

  module_versions = {
    ami     = "1.0.0"
    compute = "1.0.0"
    network = "1.0.0"
    alb     = "1.0.0"
    dns     = "1.0.0"
    storage = "1.0.0"
    iam     = "1.0.0"
    vpc     = "1.0.0"
  }
}

locals {
  profiles = {
    personal = {
      environment = "dev"
      cost_center = "personal"
      application = "ec2-demo"
      owner       = "Raymon_Epping"
      region      = "eu-north-1"
    }

    workshop = {
      environment = "workshop"
      cost_center = "training"
      application = "ec2-alb-demo"
      owner       = "workshop-team"
      region      = "eu-west-1"
    }
  }

  profile_settings = lookup(local.profiles, var.profile, local.profiles.personal)
}

locals {
  effective_region      = coalesce(var.region, local.profile_settings.region)
  effective_environment = coalesce(var.environment, local.profile_settings.environment)
  effective_cost_center = coalesce(var.cost_center, local.profile_settings.cost_center)
  effective_application = coalesce(var.application, local.profile_settings.application)
  effective_owner       = coalesce(var.owner, local.profile_settings.owner)
}

##############################################################################
# AMI resolution
##############################################################################
locals {
  # Choose between explicit AMI and the dynamic lookup module.
  effective_ami_id = module.ami.ami_id
}

##############################################################################
# VPC and subnet resolution
##############################################################################

locals {
  # Base VPC ID from user inputs and lookups
  base_vpc_id = (
    var.vpc_id != "" ? var.vpc_id :
    (var.vpc_name != "" && length(data.aws_vpc.selected_by_name) > 0
      ? data.aws_vpc.selected_by_name[0].id
    : null)
  )

  # Whether we are using the managed VPC module
  use_managed_vpc = var.enable_stack && var.enable_vpc && length(module.vpc) > 0

  # Final VPC id that all modules should use
  effective_vpc_id = local.use_managed_vpc ? module.vpc[0].vpc_id : local.base_vpc_id

  # Subnets discovered by tag when explicit subnet_ids are not provided
  discovered_subnet_ids = length(data.aws_subnets.selected_by_tier) > 0 ? data.aws_subnets.selected_by_tier[0].ids : []

  # Final subnet list that ALB and compute will use
  effective_subnet_ids = local.use_managed_vpc ? module.vpc[0].public_subnet_ids : (length(var.subnet_ids) > 0 ? var.subnet_ids : local.discovered_subnet_ids)

  # Single subnet used for EC2 instances
  effective_subnet_id = (
    var.instance_subnet_id != null && var.instance_subnet_id != "" ?
    var.instance_subnet_id :
    (length(local.effective_subnet_ids) > 0 ? local.effective_subnet_ids[0] : null)
  )
}
