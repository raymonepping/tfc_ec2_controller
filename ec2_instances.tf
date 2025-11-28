##############################################################################
# EC2 instances in the given VPC and subnet
##############################################################################

resource "aws_instance" "web_server" {
  count                       = 2
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  key_name                    = var.ssh_key_name
  associate_public_ip_address = true

  tags = merge(
    var.tags,
    {
      Name = "${var.instance_name_prefix}-web-server-${count.index + 1}"
    }
  )
}
