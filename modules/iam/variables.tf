variable "role_name" {
  description = "Name of the IAM role for EC2 instances"
  type        = string
}

variable "instance_profile_name" {
  description = "Name of the IAM instance profile"
  type        = string
}

variable "policy_arns" {
  description = "List of IAM policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to IAM resources where supported"
  type        = map(string)
  default     = {}
}
