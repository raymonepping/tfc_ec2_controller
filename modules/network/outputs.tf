output "vpc_id" {
  description = "Selected VPC ID."
  value       = data.aws_vpc.selected.id
}

output "subnet_id_effective" {
  description = "Subnet ID effectively used."
  value       = local.subnet_id_effective
}

output "security_group_id" {
  description = "ID of the created security group."
  value       = aws_security_group.this.id
}

output "subnet_ids" {
  description = "All default subnets in the selected VPC that match the filter."
  value       = data.aws_subnets.selected.ids
}
