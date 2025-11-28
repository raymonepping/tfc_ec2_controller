##############################################################################
# Security group in existing VPC (rules only pattern)
##############################################################################

resource "aws_security_group" "this" {
  name                   = var.security_group_name
  description            = "Security group for EC2 instances"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  tags = merge(
    var.tags,
    {
      Name = var.security_group_name
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "ssh_ingress" {
  for_each = toset(var.ssh_ingress_cidr)

  security_group_id = aws_security_group.this.id
  description       = "SSH Access"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value

  tags = {
    Name = "SSH Access"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http_ingress" {
  for_each = toset(var.http_ingress_cidr)

  security_group_id = aws_security_group.this.id
  description       = "HTTP Access"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value

  tags = {
    Name = "HTTP Access"
  }
}

resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.this.id

  description = "Allow all outbound traffic"
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "All Outbound Traffic"
  }
}
