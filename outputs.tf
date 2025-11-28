output "instance_ids" {
  description = "IDs of the created EC2 instances."
  value       = module.compute.instance_ids
}

output "instance_public_ips" {
  description = "Public IPs of the created EC2 instances."
  value       = module.compute.instance_public_ips
}

output "security_group_id" {
  description = "ID of the security group used by the instances."
  value       = module.network.security_group_id
}

output "vpc_id" {
  description = "ID of the VPC where resources are created."
  value       = module.network.vpc_id
}

output "subnet_id_effective" {
  description = "Subnet ID that was effectively used for the instances."
  value       = module.network.subnet_id_effective
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = module.alb.dns_name
}

