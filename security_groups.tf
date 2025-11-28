##############################################################################
# Security group for EC2 instances (rules-only pattern)
##############################################################################

resource "aws_security_group" "this" {
  name                   = var.security_group_name
  description            = "Security group for EC2 instances"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  # No inline ingress/egress rules - all managed via separate VPC security group rule resources

  tags = merge(
    var.tags,
    {
      Name = var.security_group_name
    }
  )
}

# SSH ingress
resource "aws_vpc_security_group_ingress_rule" "ssh_ingress_aap_aws_range" {
  security_group_id = aws_security_group.this.id

  description = "SSH Access - AAP AWS IP Range"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "SSH Access - AAP AWS Range"
  }
}

# HTTP ingress
resource "aws_vpc_security_group_ingress_rule" "http_ingress" {
  security_group_id = aws_security_group.this.id

  description = "HTTP Access"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "HTTP Access - 0.0.0.0/0"
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
