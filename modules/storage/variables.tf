variable "create_data_volumes" {
  description = "Whether to create and attach data volumes"
  type        = bool
  default     = false
}

variable "instance_ids" {
  description = "IDs of EC2 instances to attach volumes to"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones for each instance, same order as instance_ids"
  type        = list(string)
}

variable "volume_size" {
  description = "Size in GiB for each data volume"
  type        = number
}

variable "volume_type" {
  description = "EBS volume type for data volumes"
  type        = string
}

variable "device_name" {
  description = "Device name to attach the volume as, for example /dev/xvdb"
  type        = string
}

variable "volume_name_prefix" {
  description = "Prefix for the Name tag of data volumes"
  type        = string
}

variable "tags" {
  description = "Base tags to apply to volumes"
  type        = map(string)
  default     = {}
}
