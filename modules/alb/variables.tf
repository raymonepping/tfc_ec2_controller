variable "vpc_id" {
  description = "VPC ID for the ALB"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the ALB"
  type        = list(string)
}

variable "instance_ids" {
  description = "Instance IDs to register in the target group"
  type        = list(string)
}

variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
}

variable "listener_port" {
  description = "Port ALB will listen on"
  type        = number
  default     = 80
}

variable "target_port" {
  description = "Port on the instances"
  type        = number
  default     = 80
}

variable "tags" {
  description = "Tags to apply to ALB resources"
  type        = map(string)
}
