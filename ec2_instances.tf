resource "aws_instance" "web_server" {
  count = var.instance_count

  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = var.ssh_key_name
  associate_public_ip_address = true

  tags = merge(
    var.tags,
    {
      Name = "${var.instance_name_prefix}-web-server-${count.index + 1}"
    }
  )
}
