##############################################################################
# EC2 instances
##############################################################################

resource "aws_instance" "web_server" {
  count                       = var.instance_count
  ami                         = data.aws_ami.rhel_10.id
  instance_type               = var.instance_type
  subnet_id                   = local.subnet_id_effective
  vpc_security_group_ids      = [aws_security_group.this.id]
  key_name                    = var.ssh_key_name
  associate_public_ip_address = true

  # Optional: basic volume hardening
  root_block_device {
    encrypted = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.instance_name_prefix}-web-server-${count.index + 1}"
    }
  )

  # Note: action_trigger is a very new feature; I cannot validate it against
  # current docs in my environment. If it works in your 1.14 tests, keep it;
  # otherwise you may want to temporarily comment it out when debugging.

  lifecycle {
    action_trigger {
      events  = [after_create]
      actions = [action.aap_eda_eventstream_post.create]
    }
  }
}
