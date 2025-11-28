variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "security_group_name" {
  description = "Name for the EC2 security group"
  type        = string
}

variable "ssh_ingress_cidr" {
  description = "CIDR ranges allowed for SSH"
  type        = list(string)
}

variable "http_ingress_cidr" {
  description = "CIDR ranges allowed for HTTP"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to the security group"
  type        = map(string)
}
