variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances"
  type        = number
}

variable "instance_name_prefix" {
  description = "Prefix for the EC2 Name tag"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where EC2 instances will be launched"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID to attach to the instances"
  type        = string
}

variable "ssh_key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

variable "tags" {
  description = "Tags to apply to instances"
  type        = map(string)
}

variable "root_volume_size" {
  description = "Root volume size in GiB for the EC2 instances."
  type        = number
  default     = 10
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
  description = "Device name to use for the additional data volume."
  type        = string
  default     = "/dev/sdf"
}


variable "architecture" {
  description = "Expected AMI architecture, used for lifecycle precondition checks"
  type        = string
  default     = "x86_64"
}
