output "vpc_id" {
  description = "ID of the managed VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets in the managed VPC"
  value       = [for s in aws_subnet.public : s.id]
}
