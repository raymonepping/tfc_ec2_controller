variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
}

variable "instance_name_prefix" {
  description = "Prefix for the instance Name tag"
  type        = string
}

variable "ssh_key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where instances will be created"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for the instances"
  type        = string
}

variable "tags" {
  description = "Base tags to apply to instances"
  type        = map(string)
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances (resolved in the root module)"
  type        = string
}
