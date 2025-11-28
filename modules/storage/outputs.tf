output "volume_ids" {
  description = "IDs of data EBS volumes created for each EC2 instance"
  value       = aws_ebs_volume.this[*].id
}

output "volume_names" {
  description = "Names of the data EBS volumes"
  value       = [
    for v in aws_ebs_volume.this :
    v.tags["Name"]
  ]
}

output "attachment_ids" {
  description = "IDs of the volume attachments (empty if data volumes are disabled)"
  value       = var.create_data_volumes ? aws_volume_attachment.this[*].id : []
}
