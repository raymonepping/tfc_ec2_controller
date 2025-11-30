##############################################################################
# Root variables: region and network
##############################################################################

variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "eu-north-1"
}

variable "vpc_id" {
  description = "Existing VPC ID where EC2 and ALB will live."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs in the VPC, used by ALB and EC2."
  type        = list(string)
}

variable "instance_subnet_id" {
  description = "Subnet ID to place EC2 instances in. If null, the first element of subnet_ids is used."
  type        = string
  default     = null
}

##############################################################################
# Compute instance configuration
##############################################################################

variable "os_type" {
  description = "AMI OS channel to use (rhel10 default, or rhel9)"
  type        = string
  default     = "rhel10"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of EC2 instances behind the ALB."
  type        = number
  default     = 2
}

variable "instance_name_prefix" {
  description = "Prefix for the Name tag of EC2 instances."
  type        = string
  default     = "rhel-demo"
}

variable "ssh_key_name" {
  description = "Existing EC2 key pair name used for SSH access."
  type        = string
}

variable "security_group_name" {
  description = "Name for the EC2 instance security group."
  type        = string
  default     = "ec2-instances-sg"
}

variable "ssh_ingress_cidr" {
  description = "CIDR ranges allowed to SSH to the instances."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "http_ingress_cidr" {
  description = "CIDR ranges allowed to HTTP to the instances."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

##############################################################################
# AMI selection and lifecycle guardrail
##############################################################################

variable "ami_id" {
  description = "Optional override for the AMI ID. If null, use the default RHEL 10 AMI for the region."
  type        = string
  default     = null
}

variable "architecture" {
  description = "Expected AMI architecture, passed into the compute module for lifecycle precondition checks."
  type        = string
  default     = "x86_64"
}

##############################################################################
# Legacy / base tags map (kept for extension if needed)
##############################################################################

variable "tags" {
  description = "Base tags map. Currently not wired into the tags module, but kept for future extension."
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
  description = "Device name to use for the additional data volume (for example /dev/xvdb)."
  type        = string
  default     = "/dev/xvdb"
}

##############################################################################
# Tagging metadata for the tags module
##############################################################################

variable "environment" {
  description = "Environment name for tagging (for example dev, stage, prod)."
  type        = string
}

variable "cost_center" {
  description = "Cost center for tagging."
  type        = string
}

variable "application" {
  description = "Application name for tagging."
  type        = string
}

variable "owner" {
  description = "Owner or team for tagging."
  type        = string
}

variable "extra_tags" {
  description = "Optional extra tags to merge into the base tag set."
  type        = map(string)
  default     = {}
}

##############################################################################
# DNS integration (Route 53)
##############################################################################

variable "create_dns_record" {
  description = "Whether to create a Route53 record for the ALB."
  type        = bool
  default     = false
}

variable "route53_zone_id" {
  description = "Route53 hosted zone id where the record will be created."
  type        = string
  default     = ""
}

variable "route53_record_name" {
  description = "DNS record name for the ALB, for example ec2-demo.example.com."
  type        = string
  default     = ""
}

##############################################################################
# IAM configuration
##############################################################################

variable "iam_role_name" {
  description = "Name of the IAM role used by EC2 instances"
  type        = string
  default     = "ec2-demo-role"
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile for EC2 instances"
  type        = string
  default     = "ec2-demo-instance-profile"
}

variable "iam_policy_arns" {
  description = "List of IAM policy ARNs to attach to the EC2 role"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

##############################################################################
# Managed VPC configuration (used when enable_vpc = true)
##############################################################################

variable "vpc_cidr_block" {
  description = "CIDR block for the managed VPC (only used when enable_vpc = true)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_azs" {
  description = "Availability zones to use for public subnets when creating a VPC"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets when creating a VPC (must match length of vpc_azs)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
