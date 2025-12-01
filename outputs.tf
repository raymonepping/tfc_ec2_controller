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
  description = "Security group id for the EC2 instances, if created"
  value       = local.use_network && length(module.network) > 0 ? module.network[0].security_group_id : ""
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
  value       = var.enable_stack && var.enable_alb && var.enable_dns && length(module.dns) > 0 ? module.dns[0].record_fqdn : ""
}

##############################################################################
# Storage (feature flag aware)
##############################################################################

output "data_volume_ids" {
  description = "EBS data volume IDs created for the EC2 instances"
  value       = var.enable_stack && var.enable_storage && length(module.storage) > 0 ? module.storage[0].volume_ids : []
}

output "data_volume_names" {
  description = "EBS data volume names created for the EC2 instances"
  value       = var.enable_stack && var.enable_storage && length(module.storage) > 0 ? module.storage[0].volume_names : []
}

output "data_volume_attachments" {
  description = "IDs of the data volume attachments"
  value       = var.enable_stack && var.enable_storage && length(module.storage) > 0 ? module.storage[0].attachment_ids : []
}

output "iam_role_name" {
  description = "IAM role name used by the EC2 instances (empty if IAM disabled)"
  value       = var.enable_stack && var.enable_iam && length(module.iam) > 0 ? module.iam[0].role_name : ""
}

output "iam_instance_profile_name" {
  description = "IAM instance profile name attached to EC2 (empty if IAM disabled)"
  value       = var.enable_stack && var.enable_iam && length(module.iam) > 0 ? module.iam[0].instance_profile_name : ""
}

output "vpc_id_effective" {
  description = "VPC ID actually used by the stack (managed or existing)"
  value       = local.effective_vpc_id
}

output "subnet_ids_effective" {
  description = "Subnet IDs actually used by the stack (managed or existing)"
  value       = local.effective_subnet_ids
}


output "stack_version" {
  description = "Version label for this EC2 control panel stack"
  value       = local.stack_version
}

output "module_versions" {
  description = "Internal version map of included modules"
  value       = local.module_versions
}

output "module_versions_json" {
  description = "Module versions as a JSON string for dashboards or tooling"
  value       = jsonencode(local.module_versions)
}
