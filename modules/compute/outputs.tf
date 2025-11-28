output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = [for i in aws_instance.web_server : i.id]
}

output "public_ips" {
  description = "Public IPs of the EC2 instances"
  value       = [for i in aws_instance.web_server : i.public_ip]
}

output "instance_azs" {
  description = "Availability zones of the EC2 instances, in the same order as instance_ids."
  value       = [for i in aws_instance.web_server : i.availability_zone]
}
