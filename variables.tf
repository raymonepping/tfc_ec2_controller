variable "region" {
  description = "AWS region."
  type        = string
  default     = "eu-north-1"
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instances (from ami_lookup.sh)."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the instances will be launched."
  type        = string
}

variable "security_group_ids" {
  description = "List of existing security group IDs to attach to the instances."
  type        = list(string)
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

variable "instance_name_prefix" {
  description = "Prefix for Name tag."
  type        = string
  default     = "test"
}

variable "ssh_key_name" {
  description = "SSH key pair name."
  type        = string
  default     = "techxchangenl"
}

variable "tags" {
  description = "Base tags to apply."
  type        = map(string)
  default = {
    Terraform  = "true"
    CostCenter = "personal"
    OS         = "RHEL"
    Role       = "webserver"
  }
}
