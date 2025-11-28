output "volume_ids" {
  description = "IDs of created data volumes"
  value       = aws_ebs_volume.data[*].id
}

output "attachments" {
  description = "Volume attachment resources"
  value       = aws_volume_attachment.this[*].id
}
