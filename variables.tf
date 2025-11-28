##############################################################################
# Variables File
##############################################################################

variable "region" {
  description = "The region where the resources are created."
  type        = string
  default     = "eu-north-1"
}

variable "instance_name_prefix" {
  description = "Prefix for the name tag of EC2 instances"
  type        = string
  default     = "test"
}

variable "address_space" {
  description = "Unused in this version. Kept for compatibility."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "Unused in this version. Kept for compatibility."
  type        = string
  default     = "10.0.10.0/24"
}

variable "instance_type" {
  description = "Specifies the AWS instance type."
  type        = string
  default     = "t3.micro"
}

variable "security_group_name" {
  description = "Name for the security group"
  type        = string
  default     = "ec2-instances-sg"
}

variable "vpc_id" {
  description = "VPC ID to create resources in. Must be provided, as DescribeVpcs is not available."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID to launch the instances in. Must be provided, as subnet discovery is not available."
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instances (for example from ami_lookup.sh)."
  type        = string
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair to use for the instances"
  type        = string
  default     = "techxchangenl"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Terraform  = "true"
    CostCenter = "personal"
    OS         = "RHEL"
    Role       = "webserver"
  }
}
