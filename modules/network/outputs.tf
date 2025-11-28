output "vpc_id" {
  description = "VPC ID used by the network module."
  value       = var.vpc_id
}

output "subnet_ids" {
  description = "All subnet IDs passed into the network module."
  value       = var.subnet_ids
}

output "subnet_id_effective" {
  description = "Subnet ID used for EC2 instances."
  value       = local.subnet_id_effective
}

output "security_group_id" {
  description = "Security group ID for EC2 instances."
  value       = aws_security_group.this.id
}
