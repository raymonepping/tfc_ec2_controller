##############################################################################
# Root level variables
##############################################################################

variable "region" {
  description = "The region where the resources are created."
  type        = string
  default     = "eu-north-1"
}

variable "instance_name_prefix" {
  description = "Prefix for the name tag of EC2 instances."
  type        = string
  default     = "test"
}

variable "address_space" {
  description = "Address space for a future custom VPC. Currently unused."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "Subnet prefix for a future custom subnet. Currently unused."
  type        = string
  default     = "10.0.10.0/24"
}

variable "instance_type" {
  description = "Specifies the AWS instance type."
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of EC2 instances to create."
  type        = number
  default     = 2
}

variable "security_group_name" {
  description = "Name for the security group."
  type        = string
  default     = "ec2-instances-sg"
}

variable "vpc_id" {
  description = "VPC ID to create resources in. If null, the default VPC will be used."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID to launch the instances in. If null, a default subnet is used."
  type        = string
  default     = null
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair to use for the instances."
  type        = string
  default     = "techxchangenl"
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default = {
    Terraform  = "true"
    CostCenter = "personal"
    OS         = "RHEL"
    Role       = "webserver"
  }
}

variable "ssh_ingress_cidr" {
  description = "CIDR blocks allowed to SSH into the instances."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "http_ingress_cidr" {
  description = "CIDR blocks allowed to access HTTP on the instances."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_aap_actions" {
  description = "Enable AAP EDA action triggers on EC2 instances."
  type        = bool
  default     = false
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instances (pre-selected via ami_lookup.sh)."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs in the VPC. Used for ALB and for picking an instance subnet."
  type        = list(string)
}
