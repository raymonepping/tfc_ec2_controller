variable "create_data_volumes" {
  description = "Whether to create and attach data volumes"
  type        = bool
  default     = false
}

variable "instance_ids" {
  description = "IDs of instances to attach the volumes to"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones for each instance"
  type        = list(string)
}

variable "volume_size" {
  description = "Size in GiB for each data volume"
  type        = number
}

variable "volume_type" {
  description = "Volume type for the data volumes"
  type        = string
}

variable "device_name" {
  description = "Device name to use when attaching the volume"
  type        = string
}

variable "volume_name_prefix" {
  description = "Prefix for the Name tag of the volumes"
  type        = string
}

variable "tags" {
  description = "Base tags to apply to volumes"
  type        = map(string)
}
