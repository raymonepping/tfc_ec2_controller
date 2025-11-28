# EC2 instances in default VPC

locals {
  subnet_id = var.subnet_id != null ? var.subnet_id : data.aws_subnets.default.ids[0]
}

# Create EC2 instances
resource "aws_instance" "web_server" {
  count                       = 2
  ami                         = data.aws_ami.rhel_10.id
  instance_type               = var.instance_type
  subnet_id                   = local.subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  key_name                    = var.ssh_key_name
  associate_public_ip_address = true

  tags = merge(
    var.tags,
    {
      Name = "${var.instance_name_prefix}-web-server-${count.index + 1}"
    }
  )
  lifecycle {
    # This action triggers syntax new in terraform
    # It configures terraform to run the listed actions based
    # on the named lifecycle events: "After creating this resource, run the action"
    action_trigger {
      events  = [after_create]
      actions = [action.aap_eda_eventstream_post.create]
    }
  }
}