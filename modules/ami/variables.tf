variable "os_type" {
  description = "AMI OS channel to use (for example rhel10, rhel9)"
  type        = string
  default     = "rhel10"
}

variable "architecture" {
  description = "Instance architecture (x86_64 or arm64)"
  type        = string
  default     = "x86_64"
}

variable "ami_id_override" {
  description = "Explicit AMI ID to use. If non-empty, lookup is skipped."
  type        = string
  default     = ""
}
