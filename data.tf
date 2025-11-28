###############################################################################
# AMI lookup for RHEL in the current region
#
# Rules:
# - If var.ami_id is set, that ID is used directly and no lookup is done.
# - Otherwise we search for the most recent AMI matching:
#     - owners            = var.ami_owners
#     - name patterns     = var.ami_name_patterns
#     - platform-details  = var.ami_platform_details (optional)
#     - x86_64, HVM, EBS
###############################################################################

locals {
  use_explicit_ami = var.ami_id != ""
}

data "aws_ami" "rhel" {
  count       = local.use_explicit_ami ? 0 : 1
  most_recent = true
  owners      = var.ami_owners

  filter {
    name   = "name"
    values = var.ami_name_patterns
  }

  # Optional platform details filter, used by default for RHEL
  dynamic "filter" {
    for_each = length(var.ami_platform_details) > 0 ? [1] : []
    content {
      name   = "platform-details"
      values = var.ami_platform_details
    }
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Single point of truth for the AMI ID used by instances
locals {
  effective_ami_id = local.use_explicit_ami ? var.ami_id : data.aws_ami.rhel[0].id
}
