region = "eu-north-1"

# Pick one of the subnets from DescribeSubnets
subnet_id         = "subnet-0023ccee8b48c4720" # eu-north-1c, for example
security_group_id = "sg-0150c38f5b8200ec5"     # the SG you just created

# AMI you successfully used from the console
ami_id = "ami-08526b399bb6eb2c7"

instance_type        = "t3.micro"
instance_name_prefix = "rhel-demo"
instance_count       = 2
