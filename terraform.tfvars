# RHEL 10 AMI from ami_lookup.sh
ami_id = "ami-09232a2cda00a54c3"

# Your existing VPC
vpc_id = "vpc-02ffa563ad97b1f64"

# Subnets in that VPC (example IDs – replace with your real ones)
subnet_ids = [
  "subnet-0023ccee8b48c4720",
  "subnet-01e01b9485887200d",
  "subnet-0e958bfc095b39b9e",
]

# Optional: which subnet to use for EC2 instances
# If you omit this or set "", the module will use the first subnet_ids element.
subnet_id = "subnet-0023ccee8b48c4720"
