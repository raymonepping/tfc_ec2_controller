##############################################################################
# Security group (rules-only pattern)
##############################################################################

resource "aws_security_group" "this" {
  name                   = var.security_group_name
  description            = "Security group for EC2 instances"
  vpc_id                 = data.aws_vpc.selected.id
  revoke_rules_on_delete = true

  tags = merge(
    var.tags,
    {
      Name = var.security_group_name
    }
  )
}

# SSH ingress from ssh_ingress_cidrs
resource "aws_vpc_security_group_ingress_rule" "ssh_ingress" {
  for_each = var.ssh_ingress_cidrs

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

# HTTP ingress from http_ingress_cidrs
resource "aws_vpc_security_group_ingress_rule" "http_ingress" {
  for_each = var.http_ingress_cidrs

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

# Egress: allow all outbound
resource "aws_vpc_security_group_egress_rule" "all_outbound_egress" {
  security_group_id = aws_security_group.this.id

  description = "Allow all outbound traffic"
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "All Outbound Traffic"
  }
}
