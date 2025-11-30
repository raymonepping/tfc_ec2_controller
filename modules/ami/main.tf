##############################################################################
# modules/ami - AMI lookup module
#
# Picks an AMI based on OS channel and architecture, unless an explicit
# override is provided.
#
# - If ami_id_override != "" then that value is used directly.
# - If ami_id_override == "" then the latest matching AMI is discovered.
##############################################################################

locals {
  os_filters = {
    rhel10 = {
      name   = "RHEL-10*"
      owners = ["309956199498"] # Red Hat
    }
    rhel9 = {
      name   = "RHEL-9*"
      owners = ["309956199498"] # Red Hat
    }
  }
}

# Only do a lookup when there is no explicit override
data "aws_ami" "latest" {
  count       = var.ami_id_override == "" ? 1 : 0
  most_recent = true
  owners      = local.os_filters[var.os_type].owners

  filter {
    name   = "name"
    values = [local.os_filters[var.os_type].name]
  }

  filter {
    name   = "architecture"
    values = [var.architecture]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
