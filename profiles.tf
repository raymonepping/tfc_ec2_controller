##############################################################################
# Profile map
#
# High level intent bundles for typical environments.
# Most users only set var.profile and let this map drive defaults.
##############################################################################

locals {
  profiles = {
    personal = {
      environment          = "dev"
      cost_center          = "personal"
      application          = "ec2-demo"
      owner                = "Raymon_Epping"
      ssh_key_name         = "my-keypair"
      region               = "eu-north-1"
      domain               = "raymon-epping.sbx.hashidemos.io"
      instance_type        = "t3.micro"
      instance_name_prefix = "rhel-demo"
    }

    workshop = {
      environment          = "workshop"
      cost_center          = "training"
      application          = "ec2-alb-demo"
      owner                = "workshop-team"
      ssh_key_name         = "my-keypair"
      region               = "eu-west-1"
      domain               = "raymon-epping.sbx.hashidemos.io"
      instance_type        = "t3.micro"
      instance_name_prefix = "rhel-demo"
    }
  }

  profile_settings = lookup(local.profiles, var.profile, local.profiles.personal)
}