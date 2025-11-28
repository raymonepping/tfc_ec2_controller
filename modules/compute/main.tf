##############################################################################
# EC2 instances
##############################################################################

resource "aws_instance" "web_server" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.ssh_key_name
  associate_public_ip_address = true

  # Root volume configuration
  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = true
    delete_on_termination = true
  }

  # Optional data volume
  dynamic "ebs_block_device" {
    for_each = var.data_volume_enabled ? [1] : []

    content {
      device_name           = var.data_volume_device_name
      volume_size           = var.data_volume_size
      volume_type           = var.data_volume_type
      encrypted             = true
      delete_on_termination = true
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.instance_name_prefix}-web-server-${count.index + 1}"
    }
  )
}
