output "instance_ids" {
  value       = aws_instance.web_server[*].id
  description = "IDs of the created instances."
}

output "instance_public_ips" {
  value       = aws_instance.web_server[*].public_ip
  description = "Public IPs of the created instances."
}
