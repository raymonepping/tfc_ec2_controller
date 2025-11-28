variable "vpc_id" {
  description = "VPC ID where the ALB and target group will be created."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the ALB. For internet facing ALB, use at least two subnets in different AZs."
  type        = list(string)
}

variable "instance_ids" {
  description = "IDs of instances to register as targets."
  type        = list(string)
}

variable "alb_name" {
  description = "Name of the Application Load Balancer."
  type        = string
  default     = "ec2-demo-alb"
}

variable "listener_port" {
  description = "Port on which the ALB will listen."
  type        = number
  default     = 80
}

variable "target_port" {
  description = "Port on which the instances are listening."
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "HTTP path for health checks."
  type        = string
  default     = "/"
}

variable "tags" {
  description = "Tags to apply to ALB resources."
  type        = map(string)
  default     = {}
}
