##############################################################################
# Variables File
#
# Here is where we store the default values for all the variables used in our
# Terraform code. If you create a variable with no default, the user will be
# prompted to enter it (or define it via config file or command line flags.)

variable "region" {
  description = "The region where the resources are created."
  default     = "eu-north-1"
}

variable "instance_name_prefix" {
  description = "Prefix for the name tag of EC2 instances"
  type        = string
  default     = "test"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.0.10.0/24"
}

variable "instance_type" {
  description = "Specifies the AWS instance type."
  default     = "t3.micro"
}

variable "security_group_name" {
  description = "Name for the security group"
  type        = string
  default     = "ec2-instances-sg"
}

variable "vpc_id" {
  description = "VPC ID to create resources in (if not provided, the default VPC will be used)"
  type        = string
  default     = null
}


variable "subnet_id" {
  description = "Subnet ID to launch the instances in (if not provided, a subnet from the default VPC will be used)"
  type        = string
  default     = null
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
