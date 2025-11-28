variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "vpc_id" {
  description = "Optional VPC ID. If null, the default VPC in the region is used."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Optional subnet ID. If null, a default subnet of the selected VPC is used."
  type        = string
  default     = null
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
  description = "Prefix for the Name tag of EC2 instances."
  type        = string
  default     = "test"
}

variable "security_group_name" {
  description = "Name for the security group."
  type        = string
  default     = "ec2-instances-sg"
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair to use for the instances."
  type        = string
  default     = "techxchangenl"
}

variable "ssh_ingress_cidrs" {
  description = "CIDR blocks allowed SSH access (port 22)."
  type        = set(string)
  default     = ["0.0.0.0/0"]
}

variable "http_ingress_cidrs" {
  description = "CIDR blocks allowed HTTP access (port 80)."
  type        = set(string)
  default     = ["0.0.0.0/0"]
}

variable "rhel_ami_name_prefix" {
  description = "Name filter for the RHEL 10 AMI."
  type        = string
  default     = "RHEL-10*"
}

variable "tags" {
  description = "Base tags to apply to all resources."
  type        = map(string)
  default = {
    Terraform  = "true"
    CostCenter = "personal"
    OS         = "RHEL"
    Role       = "webserver"
  }
}
