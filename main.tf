# Main Terraform file for EC2 instances in default VPC
# This configuration creates two EC2 instances in the default VPC

# Get default VPC if vpc_id is not specified
data "aws_vpc" "default" {
  default = var.vpc_id != null ? false : true
  id      = var.vpc_id != null ? var.vpc_id : null
}

# Get default subnet if subnet_id is not specified
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

data "aws_ami" "rhel_10" {
  most_recent = true
  owners      = ["309956199498"] // Red Hat's Account ID

  filter {
    name   = "name"
    values = ["RHEL-10*"]
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