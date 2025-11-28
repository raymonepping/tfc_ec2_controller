output "instance_ids" {
  description = "IDs of the created EC2 instances."
  value       = aws_instance.web_server[*].id
}

output "instance_public_ips" {
  description = "Public IPs of the created EC2 instances."
  value       = aws_instance.web_server[*].public_ip
}

output "selected_ami" {
  description = "Details about the selected RHEL 10 AMI."
  value = {
    id   = data.aws_ami.rhel_10.id
    name = data.aws_ami.rhel_10.name
  }
}
