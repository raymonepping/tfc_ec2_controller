variable "environment" {
  description = "Environment name, for example dev, test, prod"
  type        = string
}

variable "cost_center" {
  description = "Cost center or billing code"
  type        = string
}

variable "application" {
  description = "Application or service name"
  type        = string
}

variable "owner" {
  description = "Owner or team name"
  type        = string
}

variable "extra_tags" {
  description = "Additional tags that should be merged into the base set"
  type        = map(string)
  default     = {}
}
