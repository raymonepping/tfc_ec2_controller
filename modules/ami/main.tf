locals {
  # Filters per OS "channel"
  # Owner 309956199498 is the official Red Hat AWS account.
  os_filters = {
    rhel9 = {
      name   = "RHEL-9*_HVM-*-x86_64-*"
      owners = ["309956199498"]
    }

    rhel10 = {
      # Based on names like:
      # RHEL-10.1.0_HVM_GA-20251031-x86_64-0-Hourly2-GP3
      # RHEL-10.0.0_HVM-20251030-x86_64-0-Hourly2-GP3
      name   = "RHEL-10*"
      owners = ["309956199498"]
    }

    # Alias for backwards compatibility. Uses RHEL 10 channel.
    redhat = {
      name   = "RHEL-10*"
      owners = ["309956199498"]
    }
  }
}

# Only do a lookup when no explicit AMI override is supplied.
data "aws_ami" "latest" {
  count       = var.ami_id_override == "" ? 1 : 0
  most_recent = true

  owners = local.os_filters[var.os_type].owners

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
}
