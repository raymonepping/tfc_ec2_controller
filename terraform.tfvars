##############################################################################
# Tagging metadata
# These flow into the tags module and end up on every resource
##############################################################################
environment = "dev"
cost_center = "personal"
application = "ec2-alb-demo"
owner       = "raymon"

##############################################################################
# AWS region and networking
##############################################################################
region = "eu-north-1"

# Existing VPC and subnets to place EC2 + ALB in
vpc_id = "vpc-02ffa563ad97b1f64"

subnet_ids = [
  "subnet-0023ccee8b48c4720",
  "subnet-01e01b9485887200d",
  "subnet-0e958bfc095b39b9e",
]

##############################################################################
# EC2 instance settings
##############################################################################
# instance_count       = 5
instance_type        = "t3.micro"
instance_name_prefix = "rhel-demo"

# Existing EC2 key pair name for SSH access
ssh_key_name = "my-keypair"

##############################################################################
# AMI and lifecycle guardrail
##############################################################################
# ami_id = "ami-08526b399bb6eb2c7"
# If left empty, the ami_lookup module will automatically pick
# the latest RHEL 10 image in the region.
ami_id = ""

# This is validated by the compute module lifecycle precondition.
# Change this to a wrong architecture to see the guardrail in action.
architecture = "x86_64"

##############################################################################
# Storage configuration (additional data volume per instance)
##############################################################################

data_volume_enabled     = true
data_volume_size        = 50
data_volume_type        = "gp3"
data_volume_device_name = "/dev/xvdb"

##############################################################################
# DNS integration (Route53 alias record for the ALB)
##############################################################################

# When true, the dns module creates an A record in this hosted zone
# that aliases to the ALB DNS name.
create_dns_record = true

route53_zone_id     = "Z08325331FB981V6E7LSO"
route53_record_name = "ec2-demo.raymon-epping.sbx.hashidemos.io"
