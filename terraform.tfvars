# Tagging metadata
environment = "dev"
cost_center = "personal"
application = "ec2-alb-demo"
owner       = "raymon"

region = "eu-north-1"

vpc_id = "vpc-02ffa563ad97b1f64"

subnet_ids = [
  "subnet-0023ccee8b48c4720",
  "subnet-01e01b9485887200d",
  "subnet-0e958bfc095b39b9e",
]

# Instance details
instance_subnet_id   = "subnet-0023ccee8b48c4720"
instance_type        = "t3.micro"
instance_count       = 2
instance_name_prefix = "rhel-demo"

# Existing EC2 key pair name 
ssh_key_name = "my-keypair"

# RHEL 10 free tier AMI
ami_id       = "ami-08526b399bb6eb2c7"
architecture = "x86_64"

# Storage configuration
data_volume_enabled     = true
data_volume_size        = 50
data_volume_type        = "gp3"
data_volume_device_name = "/dev/xvdb"
