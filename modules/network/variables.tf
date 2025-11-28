variable "vpc_id" {
  description = "VPC ID. If null, the default VPC is used."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID. If null, a default subnet for the VPC is used."
  type        = string
  default     = null
}

variable "security_group_name" {
  description = "Name of the security group."
  type        = string
}

variable "ssh_ingress_cidr" {
  description = "CIDR blocks allowed for SSH."
  type        = list(string)
}

variable "http_ingress_cidr" {
  description = "CIDR blocks allowed for HTTP."
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to the security group."
  type        = map(string)
  default     = {}
}
