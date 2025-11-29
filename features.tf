##############################################################################
# Feature flags
#
# Central switches to turn major building blocks on or off.
# Override via terraform.tfvars or a separate features.auto.tfvars file.
##############################################################################

variable "enable_stack" {
  description = "Master switch. If false, no EC2, ALB, DNS or extra storage is created"
  type        = bool
  default     = true
}

variable "enable_instances" {
  description = "Enable EC2 instances from the compute module"
  type        = bool
  default     = true
}

variable "enable_alb" {
  description = "Enable ALB + target group + listener in front of the EC2 instances"
  type        = bool
  default     = true
}

variable "enable_dns" {
  description = "Enable Route53 DNS record that points at the ALB"
  type        = bool
  default     = true
}

variable "enable_storage" {
  description = "Enable extra data EBS volumes via the storage module"
  type        = bool
  default     = true
}

variable "enable_iam" {
  description = "Enable IAM role and instance profile for EC2 instances"
  type        = bool
  default     = true
}