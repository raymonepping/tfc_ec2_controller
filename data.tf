##############################################################################
# Data sources
#
# This file keeps all shared lookups together.
# For this demo:
#   - We resolve a RHEL 10 AMI from the Red Hat publisher account
#   - We pin architecture and root device characteristics so it matches
#     the lifecycle precondition in the compute module
##############################################################################

# Discover the latest RHEL 10 x86_64 AMI in the current region.
# Owner 309956199498 is the official Red Hat AWS account.
data "aws_ami" "rhel_10" {
  most_recent = true
  owners      = ["309956199498"] # Red Hat

  # Match RHEL 10 images
  filter {
    name   = "name"
    values = ["RHEL-10*"]
  }

  # Align with the lifecycle guardrail: we only accept x86_64
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  # Root volume on EBS
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  # HVM virtualization, standard for modern EC2
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
