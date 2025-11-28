# Example tfvars for the flat EC2 + SG setup

region = "eu-north-1"

# Existing VPC and subnet (you already used these when launching manually)
vpc_id    = "vpc-02ffa563ad97b1f64"
subnet_id = "subnet-0023ccee8b48c4720"

# RHEL 10 AMI you tested manually
ami_id = "ami-08526b399bb6eb2c7"

# Optional overrides
instance_type        = "t3.micro"
instance_name_prefix = "rhel-demo"

# ssh_key_name = "techxchangenl" # keep default or override if needed

# tags = { ... } # can override defaults if desired
