variable "region" {
  description = "AWS region where the instances are created."
  type        = string
  default     = "eu-north-1"
}

variable "instance_name_prefix" {
  description = "Prefix for the Name tag of EC2 instances."
  type        = string
  default     = "test"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of EC2 instances to create."
  type        = number
  default     = 2
}

variable "subnet_id" {
  description = "Existing subnet ID to launch the instances in."
  type        = string
}

variable "security_group_id" {
  description = "Existing security group ID to attach to the instances."
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instances."
  type        = string
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair to use for the instances."
  type        = string
  default     = "techxchangenl"
}

variable "tags" {
  description = "Tags to apply to all instances."
  type        = map(string)
  default = {
    Terraform  = "true"
    CostCenter = "personal"
    OS         = "RHEL"
    Role       = "webserver"
  }
}
