region = "eu-north-1"

# From the console (the same subnet and SG you used when launching manually)
subnet_id = "subnet-0023ccee8b48c4720"
# security_group_id = "sg-xxxxxxxxxxxxxxxxx" # put your existing SG ID here

# RHEL 10 AMI you tested manually
# ami_id = "ami-08526b399bb6eb2c7"

instance_type        = "t3.micro"
instance_name_prefix = "rhel-demo"
# instance_count       = 2

# ssh_key_name = "techxchangenl" # override if needed
# tags = { ... }                  # override defaults if you want
