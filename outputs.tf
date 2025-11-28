output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = module.compute.instance_ids
}

output "instance_public_ips" {
  description = "Public IPs of the EC2 instances"
  value       = module.compute.public_ips
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = module.alb.dns_name
}

output "alb_http_url" {
  description = "HTTP URL of the Application Load Balancer."
  value       = "http://${module.alb.dns_name}"
}

output "security_group_id" {
  description = "ID of the EC2 instances security group"
  value       = module.network.security_group_id
}

output "subnet_id_effective" {
  description = "Subnet ID used for the instances"
  value       = local.effective_subnet_id
}

output "instance_azs" {
  description = "Availability zones of the EC2 instances created by the compute module."
  value       = module.compute.instance_azs
}

output "alb_fqdn" {
  description = "Route53 DNS name pointing at the ALB (if created)"
  value       = module.dns.record_fqdn
}
