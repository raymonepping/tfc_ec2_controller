##############################################################################
# Main Terraform file
#
# The actual resources are defined in:
#   - security_groups.tf
#   - ec2_instances.tf
#
# This configuration:
#   - Uses existing VPC, subnet, and AMI (all passed in as variables)
#   - Creates one security group with rules-only pattern
#   - Creates two EC2 instances in the given subnet and VPC
##############################################################################
