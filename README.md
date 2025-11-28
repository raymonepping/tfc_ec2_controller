````markdown
# EC2 + ALB Modular Demo with Terraform

This project provisions a small, opinionated EC2 and ALB setup in an existing AWS VPC using a modular Terraform layout.

It is designed to be:

- Simple enough for a workshop or demo
- Structured enough to extend into something more serious
- Safe enough to show good habits (tags, lifecycle checks, Route53, separate storage)

---

## What this configuration creates

Given an existing VPC, subnets and key pair, this stack will:

- Create a security group for EC2 instances with SSH and HTTP access
- Launch a configurable number of RHEL instances behind an Application Load Balancer
- Attach optional data volumes to each instance via a dedicated storage module
- Tag everything with a consistent tag set (environment, cost center, application, owner)
- Optionally create a Route53 DNS record that points at the ALB

By default it uses a RHEL 10 AMI from the Red Hat account. You can override the AMI if you want.

---

## High level architecture

**Inputs**

- Existing VPC ID
- Existing subnets in that VPC
- Existing EC2 key pair
- Optional Route53 hosted zone and record name

**Resources created**

- `aws_security_group` for instances plus separate ingress and egress rules
- Two EC2 instances of type `t3.micro` by default
- One Application Load Balancer with a single HTTP listener and target group
- One security group for the ALB
- Optional EBS data volumes attached to each instance
- Optional Route53 alias record that points to the ALB

---

## Repository layout

```text
./
├── backend.tf          # Local state backend (terraform.tfstate in this folder)
├── data.tf             # Data sources (RHEL 10 AMI lookup)
├── main.tf             # Root composition of all modules
├── outputs.tf          # Root outputs
├── providers.tf        # Provider definition (AWS, version constraints)
├── terraform.tfvars    # Example values for this environment
├── variables.tf        # Root input variables
└── modules/
    ├── alb/
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── compute/
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── dns/
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── network/
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── storage/
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    └── tags/
        ├── main.tf
        └── outputs.tf
````

---

## Modules

### `modules/network`

Responsible for network level access for the EC2 instances.

Creates:

* `aws_security_group.this` for the instances
* `aws_vpc_security_group_ingress_rule.ssh_ingress` for SSH
* `aws_vpc_security_group_ingress_rule.http_ingress` for HTTP
* `aws_vpc_security_group_egress_rule.all_outbound` for outbound traffic

Inputs (root wired):

* `vpc_id`
* `security_group_name`
* `ssh_ingress_cidr`
* `http_ingress_cidr`
* `tags`

Output:

* `security_group_id` used by the compute module

Pattern used:

* Rules only security group. The group itself has no inline rules. All ingress and egress rules are separate resources, which improves drift detection and troubleshooting.

---

### `modules/compute`

Responsible for the EC2 instances behind the ALB.

Creates:

* `aws_instance.web_server[count]` with:

  * AMI from `local.effective_ami_id`
  * `root_block_device` configured and encrypted
  * Public IP enabled for demo access

Key features:

* `count` driven scaling via `var.instance_count`
* Lifecycle guardrails:

  ```hcl
  lifecycle {
    # Hard requirement: we only accept 64-bit AMIs
    precondition {
      condition     = var.architecture == "x86_64"
      error_message = "The selected AMI must be x86_64. Got: ${var.architecture}"
    }

    # Sanity check: instance must have a public IP for this demo
    postcondition {
      condition     = self.public_ip != ""
      error_message = "EC2 instance must have a public IP address for this demo scenario."
    }
  }
  ```

Inputs (from root):

* `instance_type`
* `instance_count`
* `instance_name_prefix`
* `subnet_id`
* `security_group_id`
* `ssh_key_name`
* `ami_id`
* `root_volume_size`
* `root_volume_type`
* `tags`
* `architecture` (used for lifecycle precondition)

Outputs:

* `instance_ids`
* `instance_public_ips`
* `instance_azs` (used by the storage module)

---

### `modules/alb`

Responsible for the Application Load Balancer in front of the instances.

Creates:

* `aws_lb.this` (internet facing, HTTP)
* `aws_lb_target_group.this`
* `aws_lb_target_group_attachment.instances[count]`
* `aws_security_group.alb` for ALB
* `aws_vpc_security_group_ingress_rule.alb_http_ingress`
* `aws_vpc_security_group_egress_rule.alb_all_outbound`
* `aws_lb_listener.http` on port 80

Inputs:

* `vpc_id`
* `subnet_ids`
* `instance_ids`
* `alb_name`
* `listener_port`
* `target_port`
* `tags`

Outputs:

* `alb_dns_name`
* `alb_zone_id`

---

### `modules/dns`

Optional Route53 integration for a friendly DNS name.

Creates:

* `aws_route53_record.alb` with an alias to the ALB

Inputs:

* `create_record` (bool)
* `zone_id` (Route53 hosted zone)
* `record_name` (for example `ec2-demo.raymon-epping.sbx.hashidemos.io`)
* `alb_dns_name` (from the ALB module)
* `alb_zone_id` (from the ALB module)

Output:

* `record_fqdn` (used in the root output `alb_fqdn`)

If `create_record` is `false`, the module does not create any records and returns an empty string.

---

### `modules/storage`

Decouples data volumes from instance creation.

Creates for each instance (when enabled):

* `aws_ebs_volume.this[count]` in the same AZ as the instance
* `aws_volume_attachment.this[count]` attached at the configured device name

Inputs:

* `create_data_volumes`
* `instance_ids`
* `availability_zones`
* `volume_size`
* `volume_type`
* `device_name`
* `volume_name_prefix`
* `tags`

Outputs:

* `volume_ids`
* `volume_attachments`
* `volume_names`

The root module exposes these as:

* `data_volume_ids`
* `data_volume_attachments`
* `data_volume_names`

---

### `modules/tags`

Central place for tag policy.

Inputs:

* `environment`
* `cost_center`
* `application`
* `owner`
* `extra_tags` (map of additional tags)

Produces:

* `effective_tags` map with a consistent set of tags, merged with any extras.

All major resources receive `module.tags.effective_tags`, so tags stay uniform across network, compute, ALB, storage and DNS.

---

## AMI selection

The RHEL 10 AMI is discovered via `data.tf`:

```hcl
data "aws_ami" "rhel_10" {
  most_recent = true
  owners      = ["309956199498"] # Red Hat

  filter {
    name   = "name"
    values = ["RHEL-10*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
```

The root module chooses between an explicit `ami_id` and this data source:

```hcl
locals {
  effective_ami_id = (
    var.ami_id != null && var.ami_id != ""
  ) ? var.ami_id : data.aws_ami.rhel_10.id
}
```

You can override `ami_id` in `terraform.tfvars` if you want to use a specific image.

---

## Inputs and example `terraform.tfvars`

The repo includes a `terraform.tfvars` for this environment:

```hcl
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

# RHEL 10 AMI override (optional)
ami_id       = "ami-08526b399bb6eb2c7"
architecture = "x86_64"

# Storage configuration (extra data volume)
data_volume_enabled     = true
data_volume_size        = 50
data_volume_type        = "gp3"
data_volume_device_name = "/dev/xvdb"

# Route53 DNS integration
create_dns_record = true
route53_zone_id   = "Z08325331FB981V6E7LSO"
route53_record_name = "ec2-demo.raymon-epping.sbx.hashidemos.io"
```

---

## Outputs

After `terraform apply`, the root module exposes:

* `alb_dns_name`
  Raw ALB DNS name from AWS, for example `ec2-demo-alb-xxxx.eu-north-1.elb.amazonaws.com`.

* `alb_http_url`
  Convenience URL `http://<alb_dns_name>`.

* `alb_fqdn`
  Friendly DNS record from Route53, for example `ec2-demo.raymon-epping.sbx.hashidemos.io` (if DNS is enabled).

* `instance_ids`
  List of EC2 instance IDs.

* `instance_public_ips`
  List of public IPs for the instances.

* `instance_azs`
  Availability zones where instances have been placed.

* `security_group_id`
  Instance security group from the network module.

* `subnet_id_effective`
  Subnet that was chosen for instances (explicit value or first subnet from `subnet_ids`).

* `data_volume_ids`
  EBS volume IDs created by the storage module.

* `data_volume_attachments`
  Volume attachment IDs.

* `data_volume_names`
  Effective Name tags for the data volumes.

---

## Requirements

* Terraform `>= 1.6.0` (tested with 1.14.0)
* AWS provider `~> 6.0`
* Valid AWS credentials in your environment or via your preferred workflow
  (for example `doormat aws export`, IAM user, SSO, or role assumption)

You also need:

* An existing VPC and subnets
* An existing EC2 key pair in the target region
* A Route53 public hosted zone if you plan to enable DNS

---

## How to use this configuration

1. **Clone the repository**

   ```bash
   git clone <your-repo-url>
   cd tfc_ec2_controller   # or your folder name
   ```

2. **Review and edit `terraform.tfvars`**

   * Set `vpc_id`, `subnet_ids`, and `ssh_key_name` for your environment
   * Optionally change `instance_type`, `instance_count`, `data_volume_*`, and tag values
   * Enable or disable DNS and storage features as needed

3. **Initialize Terraform**

   ```bash
   terraform init
   ```

4. **Review the plan**

   ```bash
   terraform fmt
   terraform validate
   terraform plan
   ```

5. **Apply**

   ```bash
   terraform apply
   ```

   After a successful run, check:

   * `alb_http_url` for direct ALB access
   * `alb_fqdn` for the Route53 DNS endpoint if enabled

---

## Cleanup

To remove all resources created by this configuration:

```bash
terraform destroy
```

Make sure there are no extra resources attached to the instances or ALB before you destroy, to avoid dependency surprises.

---

## Extending this demo

This layout is ready for further experiments, for example:

* Adding user data and Ansible hooks for automatic configuration
* Introducing multiple target groups and ALB listener rules per path
* Wiring in additional modules, such as:

  * IAM roles and instance profiles
  * CloudWatch metrics and alarms
  * SSM Session Manager for SSH free access

For now, it stays focused on a clean, modular EC2 and ALB shape that showcases:

* Modular structure
* Tagging strategy
* Storage separation
* DNS integration
* Lifecycle guardrails

```
