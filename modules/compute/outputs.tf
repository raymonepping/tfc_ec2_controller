output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = [for i in aws_instance.web_server : i.id]
}

output "public_ips" {
  description = "Public IPs of the EC2 instances"
  value       = [for i in aws_instance.web_server : i.public_ip]
}
