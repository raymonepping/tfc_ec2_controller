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

  tags = merge(
    var.tags,
    {
      Name = "${var.instance_name_prefix}-web-server-${count.index + 1}"
    }
  )

  lifecycle {
    # New-style lifecycle usage that is actually safe and useful

    # Hard requirement: we only accept 64-bit AMIs
    precondition {
      condition     = var.architecture == "x86_64"
      error_message = "The selected AMI must be x86_64. Got: ${var.architecture}"
    }

    # Sanity check: instance must have a public IP for this demo
    postcondition {
      condition     = self.public_ip != ""
      error_message = "EC2 instance must have a public IP address for this demo scenario."
    }
  }

}
