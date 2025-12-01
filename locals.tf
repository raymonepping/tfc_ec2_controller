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
