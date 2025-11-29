##############################################################################
# Core instance & network outputs
##############################################################################

output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = module.compute.instance_ids
}

output "instance_public_ips" {
  description = "Public IPs of the EC2 instances"
  value       = module.compute.public_ips
}

output "instance_azs" {
  description = "Availability zones of the EC2 instances created by the compute module."
  value       = module.compute.instance_azs
}

output "security_group_id" {
  description = "ID of the EC2 instances security group"
  value       = module.network.security_group_id
}

output "subnet_id_effective" {
  description = "Subnet ID used for the instances"
  value       = local.effective_subnet_id
}

##############################################################################
# ALB and DNS (feature flag aware)
##############################################################################

output "alb_dns_name" {
  description = "ALB DNS name or empty string if ALB is disabled"
  value       = var.enable_stack && var.enable_alb && length(module.alb) > 0 ? module.alb[0].alb_dns_name : ""
}

output "alb_http_url" {
  description = "HTTP URL of the Application Load Balancer (empty if ALB disabled)"
  value       = var.enable_stack && var.enable_alb && length(module.alb) > 0 ? "http://${module.alb[0].alb_dns_name}" : ""
}

output "alb_fqdn" {
  description = "Route53 DNS name pointing at the ALB (empty if DNS or ALB disabled or record not created)"
  value       = var.enable_stack && var.enable_alb && var.enable_dns && var.create_dns_record && length(module.dns) > 0 ? module.dns[0].record_fqdn : ""
}

##############################################################################
# Storage (feature flag aware)
##############################################################################

output "data_volume_ids" {
  description = "EBS data volume IDs created for the EC2 instances"
  value       = var.enable_stack && var.enable_storage && var.data_volume_enabled && length(module.storage) > 0 ? module.storage[0].volume_ids : []
}

output "data_volume_names" {
  description = "EBS data volume names created for the EC2 instances"
  value       = var.enable_stack && var.enable_storage && var.data_volume_enabled && length(module.storage) > 0 ? module.storage[0].volume_names : []
}

output "data_volume_attachments" {
  description = "IDs of the data volume attachments"
  value       = var.enable_stack && var.enable_storage && var.data_volume_enabled && length(module.storage) > 0 ? module.storage[0].attachment_ids : []
}
