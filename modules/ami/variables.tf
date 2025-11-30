variable "os_type" {
  description = "The OS channel to look up (rhel10, rhel9, or redhat alias)"
  type        = string
  default     = "rhel10"

  validation {
    condition = contains(["rhel10", "rhel9", "redhat"], var.os_type)
    error_message = "os_type must be one of: rhel10, rhel9, redhat."
  }
}

variable "architecture" {
  description = "Instance architecture (x86_64 or arm64)"
  type        = string
  default     = "x86_64"
}

variable "ami_id_override" {
  description = "Explicit AMI ID. When non empty, this is used instead of doing a lookup."
  type        = string
  default     = ""
}
