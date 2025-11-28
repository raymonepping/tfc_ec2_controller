variable "create_record" {
  description = "Whether to create the Route53 record"
  type        = bool
  default     = false
}

variable "zone_id" {
  description = "Route53 hosted zone id"
  type        = string
}

variable "record_name" {
  description = "Record name to create, for example ec2-demo.example.com"
  type        = string
}

variable "alb_dns_name" {
  description = "ALB DNS name"
  type        = string
}

variable "alb_zone_id" {
  description = "ALB hosted zone id for alias target"
  type        = string
}
