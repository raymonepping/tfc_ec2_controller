##############################################################################
# Feature flags
#
# Central switches to turn major building blocks on or off.
# Override via terraform.tfvars or workspace variables.
##############################################################################

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
