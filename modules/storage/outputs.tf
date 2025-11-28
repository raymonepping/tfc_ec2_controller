output "volume_ids" {
  description = "IDs of created data volumes (empty if data volumes are disabled)"
  value       = var.create_data_volumes ? aws_ebs_volume.this[*].id : []
}

output "attachment_ids" {
  description = "IDs of the volume attachments (empty if data volumes are disabled)"
  value       = var.create_data_volumes ? aws_volume_attachment.this[*].id : []
}
