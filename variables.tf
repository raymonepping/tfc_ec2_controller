# variables.tf
variable "profile" {
  description = "High level profile that selects a bundle of defaults (personal, workshop, etc)."
  type        = string
  default     = "personal"
}

##############################################################################
# Root variables: region and network
##############################################################################

variable "region" {
  description = <<EOT
AWS region to deploy into.

If null, the region is taken from the selected profile in locals.profiles.
Typically, HCP Terraform workspaces override this via a workspace variable.
EOT
  type        = string
  default     = null
}

variable "vpc_id" {
  description = <<EOT
Existing VPC ID where EC2 and ALB will live.

If set to a non-empty string, this ID is used directly.
If left empty (""), Terraform will try to locate a VPC by tags (for example vpc_name).
EOT
  type        = string
  default     = ""
}

variable "vpc_name" {
  description = <<EOT
Optional logical VPC name to attach to, used for tag-based lookup.

When vpc_id is empty, a data source can select the VPC via tag:Name = vpc_name.
EOT
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = <<EOT
List of subnet IDs in the VPC, used by ALB and EC2.

If non-empty, these IDs are used directly.
If empty, subnets can be discovered via tags (for example Tier = "public") in the selected VPC.
EOT
  type        = list(string)
  default     = []
}

variable "subnet_tier_tag_key" {
  description = <<EOT
Tag key used to select subnets when subnet_ids are not provided.

For example "Tier" so that subnets with tag:Tier = "public" are selected.
EOT
  type        = string
  default     = "Tier"
}

variable "subnet_tier_tag_value" {
  description = <<EOT
Tag value used to select subnets when subnet_ids are not provided.

For example "public" to select public-facing subnets.
EOT
  type        = string
  default     = "public"
}

variable "instance_subnet_id" {
  description = <<EOT
Specific subnet ID to place EC2 instances in.

If null or empty, the first element of effective_subnet_ids is used.
effective_subnet_ids may come from:
- managed VPC (vpc module),
- explicit subnet_ids,
- or subnets discovered via tag-based lookups.
EOT
  type        = string
  default     = null
}

##############################################################################
# Managed VPC configuration (used when enable_vpc = true)
##############################################################################

variable "vpc_cidr_block" {
  description = "CIDR block for the managed VPC (only used when enable_vpc = true)."
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_azs" {
  description = <<EOT
Availability zones to use for public subnets when creating a VPC.

Defaults are aligned with eu-north-1 for the personal profile.
Override this in terraform.tfvars or via HCP Terraform variables when using another region.
EOT
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}

variable "public_subnet_cidrs" {
  description = <<EOT
CIDR blocks for public subnets when creating a managed VPC.

Must match the length of vpc_azs.
Only used when enable_vpc = true.
EOT
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

##############################################################################
# Compute instance configuration
##############################################################################

variable "os_type" {
  description = "AMI OS channel to use (rhel10 default, rhel9 as alternative)"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = null
}

variable "instance_count" {
  description = "Number of EC2 instances behind the ALB."
  type        = number
  default     = null
}

variable "instance_name_prefix" {
  description = "Prefix for the Name tag of EC2 instances."
  type        = string
  default     = null
}

variable "ssh_key_name" {
  description = <<EOT
Existing EC2 key pair name used for SSH access.

If null, the value is taken from the selected profile in locals.profiles.
Typically, HCP Terraform workspaces override this via a workspace variable.
EOT
  type        = string
  default     = null
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
  description = <<EOT
Optional override for the AMI ID.

If set to a non-empty string, that AMI is used directly.
If left empty (""), the ami module will automatically pick
the latest RHEL 10 image in the region for the os_type and architecture.
EOT
  type        = string
  default     = ""
}

variable "architecture" {
  description = "Expected AMI architecture, passed into the compute module for lifecycle precondition checks."
  type        = string
  default     = "x86_64"
}

##############################################################################
# Legacy / base tags map (kept for extension if needed)
##############################################################################

# variable "tags" {
#  description = "Base tags map. Currently not wired into the tags module, but kept for future extension."
#  type        = map(string)
#  default     = null
#}

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

variable "data_volume_encrypted" {
  description = "Whether the additional data volume should be encrypted"
  type        = bool
  default     = false
}

variable "data_volume_kms_key_id" {
  description = "Optional KMS key id for encrypting the data volumes. If null, AWS uses the default EBS KMS key."
  type        = string
  default     = null
}

##############################################################################
# Tagging metadata for the tags module
##############################################################################

variable "environment" {
  description = "Environment name for tagging (for example dev, stage, prod)."
  type        = string
  default     = null
}

variable "cost_center" {
  description = "Cost center for tagging."
  type        = string
  default     = null
}

variable "application" {
  description = "Application name for tagging."
  type        = string
  default     = null
}

variable "owner" {
  description = "Owner or team for tagging."
  type        = string
  default     = null
}

variable "extra_tags" {
  description = "Optional extra tags to merge into the base tag set."
  type        = map(string)
  default     = {}
}

##############################################################################
# DNS integration (Route 53)
##############################################################################

variable "root_domain" {
  description = <<EOT
Base DNS zone name (for example example.com).

If null, the value is taken from the selected profile in locals.profiles.
Used to look up the Route53 hosted zone when route53_zone_id is not provided.
EOT
  type        = string
  default     = null
}

variable "route53_zone_id" {
  description = <<EOT
Route53 hosted zone id where the record will be created.

If non-empty, this ID is used directly.
If empty, Terraform will try to locate the zone by name using root_domain.
EOT
  type        = string
  default     = ""
}

variable "route53_record_name" {
  description = <<EOT
DNS record name for the ALB, for example ec2-demo.example.com.

If empty, a default of "<application>.<root_domain>" is used.
EOT
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

variable "root_volume_encrypted" {
  description = "Whether the root volume should be encrypted."
  type        = bool
  default     = false
}

