variable "vpc_id" {
  description = "VPC ID where the security group and rules are created."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs in the VPC. Used for ALB and for choosing one subnet for EC2."
  type        = list(string)
}

variable "subnet_id" {
  description = "Optional explicit subnet ID for EC2 instances. If empty, the first subnet_ids element is used."
  type        = string
  default     = ""
}

variable "security_group_name" {
  description = "Name for the EC2 instances security group."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the security group."
  type        = map(string)
}

variable "ssh_ingress_cidr" {
  description = "CIDR blocks allowed to access SSH (port 22)."
  type        = set(string)
  default     = ["0.0.0.0/0"]  # matches your original behavior
}

variable "http_ingress_cidr" {
  description = "CIDR blocks allowed to access HTTP (port 80)."
  type        = set(string)
  default     = ["0.0.0.0/0"]  # matches your original behavior
}
