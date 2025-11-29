# features.auto.tfvars
# Central feature switches for this environment

# Master switch. Turn this off to disable the entire stack.
enable_stack = true

# Core EC2 instances
enable_instances = true

# Front door: ALB and target group
enable_alb = true

# Friendly DNS record in Route53 pointing at the ALB
enable_dns = true

# Extra EBS data volumes per instance
enable_storage = true

# IAM role and instance profile for the EC2 instances
enable_iam = false

# Use a managed VPC instead of an existing one
enable_vpc = false
