##############################################################################
# Root variables
##############################################################################

variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-north-1"
}

variable "vpc_id" {
  description = "Existing VPC ID where EC2 and ALB will live"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs in the VPC, used by ALB and EC2"
  type        = list(string)
}

variable "instance_subnet_id" {
  description = "Subnet ID to place EC2 instances in. If null, the first element of subnet_ids is used."
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of EC2 instances behind the ALB"
  type        = number
  default     = 2
}

variable "instance_name_prefix" {
  description = "Prefix for the Name tag of EC2 instances"
  type        = string
  default     = "rhel-demo"
}

variable "ssh_key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "security_group_name" {
  description = "Name for the EC2 instance security group"
  type        = string
  default     = "ec2-instances-sg"
}

variable "ssh_ingress_cidr" {
  description = "CIDR ranges allowed to SSH to the instances"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "http_ingress_cidr" {
  description = "CIDR ranges allowed to HTTP to the instances"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}


variable "ami_id" {
  description = "Optional override for the AMI ID. If null, use the default RHEL 10 AMI for the region."
  type        = string
  default     = null
}

variable "architecture" {
  description = "Expected AMI architecture, passed into the compute module for lifecycle checks"
  type        = string
  default     = "x86_64"
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

##############################################################################
# Storage configuration
##############################################################################

variable "root_volume_size" {
  description = "Root volume size in GiB for the EC2 instances."
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Root volume type for the EC2 instances."
  type        = string
  default     = "gp3"
}

variable "data_volume_enabled" {
  description = "Whether to attach an additional data volume to each EC2 instance."
  type        = bool
  default     = false
}

variable "data_volume_size" {
  description = "Size in GiB for the additional data volume."
  type        = number
  default     = 20
}

variable "data_volume_type" {
  description = "Volume type for the additional data volume."
  type        = string
  default     = "gp3"
}

variable "data_volume_device_name" {
  description = "Device name to use for the additional data volume."
  type        = string
  default     = "/dev/xvdb"
}

# Tags for resources
variable "environment" {
  description = "Environment name for tagging"
  type        = string
}

variable "cost_center" {
  description = "Cost center for tagging"
  type        = string
}

variable "application" {
  description = "Application name for tagging"
  type        = string
}

variable "owner" {
  description = "Owner or team for tagging"
  type        = string
}

variable "extra_tags" {
  description = "Optional extra tags to merge into the base tag set"
  type        = map(string)
  default     = {}
}
