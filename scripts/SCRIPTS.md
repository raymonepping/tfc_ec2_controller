# AMI Lookup Helper Scripts

This folder contains helper scripts to safely and repeatably discover Amazon Machine Images (AMIs) for use in Terraform projects.

At the moment there is one primary script:

- `ami_lookup.sh` – a flexible AMI discovery tool that outputs a slim JSON list and a readable table view.

The goal is simple:  
**Smart, not smarter.**  
You keep control. The script just does the heavy lifting for listing and filtering AMIs.

---

## 1. `ami_lookup.sh`

### 1.1. What it does

`ami_lookup.sh` is a small wrapper around `aws ec2 describe-images` that:

- Applies sensible filters for:
  - Platform (Red Hat, SUSE, Ubuntu, Debian, Amazon Linux, Windows)
  - AMI families (RHEL 9, RHEL 10, Red Hat plus SUSE)
  - Architecture, virtualization type, and root device type
- Can restrict to **official Red Hat images** by owner id.
- Can filter to **free tier eligible** images only.
- Writes a **slim JSON file** that is easy to parse or feed into Terraform decisions.
- Prints a table that makes it very easy to visually pick an AMI or name pattern.

Typical use cases:

- "Give me all free tier eligible RHEL 10 images by Red Hat in a region."
- "Show me SUSE SLES images that are free tier eligible."
- "Show me all Red Hat and SUSE images for baselining hardened builds."

---

### 1.2. Requirements

You need:

- `bash`
- `aws` CLI configured to access your AWS account
- `jq`
- Optional: a `.env` file with AWS credentials and region

Example `.env`:

```env
AWS_ACCESS_KEY_ID=your_access_key_id
AWS_SECRET_ACCESS_KEY=your_secret_access_key
AWS_SESSION_TOKEN=your_optional_session_token
AWS_REGION=eu-north-1
````

If the AWS CLI is already configured via `aws configure`, you do not need the `.env`.
The script will still read `.env` if present and use `AWS_REGION` from it when no `--region` is passed.

---

### 1.3. Script usage

```bash
./ami_lookup.sh --type TYPE [--region REGION] [--limit N] \
  [--profile PROFILE] [--json-out FILE] [--platform PLATFORM] \
  [--free-tier-only]
```

Supported `--type` values:

* `rhel`
  RHEL 9 GA style images (names like `RHEL-9*`), Red Hat owner `309956199498`.

* `rhel9`
  Explicit alias for RHEL 9 GA. Same behavior as `rhel`.

* `rhel10`
  RHEL 10 GA style images (names like `RHEL-10*`), Red Hat owner `309956199498`.

* `rhel_suse`
  All images where `platform-details` is either `Red Hat Enterprise Linux` or `SUSE Linux`.
  No owner restriction. Good for market and hardened images.

* `rhel9_std`, `rhel10_std`
  Experimental console style matching that uses `description`. Only needed if you later want to chase very specific marketplace labels. For now you can mostly ignore these.

Supported `--platform` values:

* `rhel`     – `platform-details = "Red Hat Enterprise Linux"`
* `suse`     – `platform-details = "SUSE Linux"`
* `ubuntu`   – `platform-details = "Ubuntu"`    (check once with `describe-images`)
* `debian`   – `platform-details = "Debian"`    (check once with `describe-images`)
* `amazon`   – `platform-details = "Linux/UNIX"` (broad, often used for Amazon Linux)
* `windows`  – `platform = "windows"`

Other flags:

* `--region REGION`
  AWS region. Defaults to `AWS_REGION` from environment or `.env`, or `eu-north-1`.

* `--limit N`
  Maximum number of rows to show in the table. JSON always contains the full filtered list.

* `--profile PROFILE`
  Use a specific AWS CLI profile.

* `--owner OWNER`
  Override the AMI owner id. By default:

  * RHEL types use Red Hat owner `309956199498`.
  * Other types do not restrict owner.

* `--name-filter PATTERN`
  Override the base pattern for the main filter key (name, description or platform-details depending on type). Useful for advanced cases.

* `--json-out FILE`
  Location of the output JSON file. Defaults to `ami_<type>_<platform>_<region>.json`.

* `--free-tier-only`
  Apply a client side filter on `FreeTierEligible == true` before writing JSON and printing.

---

### 1.4. Output

Each run produces:

1. A **JSON file** with a slim projection of each image:

   ```json
   [
     {
       "ImageId": "ami-09232a2cda00a54c3",
       "Name": "RHEL-10.1.0_HVM_GA-20251031-x86_64-0-Hourly2-GP3",
       "PlatformDetails": "Red Hat Enterprise Linux",
       "Description": "Provided by Red Hat, Inc.",
       "Hypervisor": "xen",
       "SourceImageId": null,
       "SourceImageRegion": null,
       "FreeTierEligible": true,
       "State": "available",
       "Architecture": "x86_64",
       "CreationDate": "2025-11-05T07:25:08.000Z"
     }
   ]
   ```

2. A **table view** for quick inspection:

   ```text
   ImageId                FreeTier  PlatformDetails           CreationDate              Name
   ami-09232a2cda00a54c3  true      Red Hat Enterprise Linux  2025-11-05T07:25:08.000Z  RHEL-10.1.0_HVM_GA-20251031-x86_64-0-Hourly2-GP3
   ...
   ```

This combination makes it easy to:

* Visually pick an AMI or name pattern.
* Script around the JSON in follow up tools or Terraform.

---

## 2. Practical examples

### 2.1. Official RHEL 10, free tier eligible

Get all official Red Hat RHEL 10 images in `eu-north-1` that are free tier eligible:

```bash
./ami_lookup.sh --type rhel10 --region eu-north-1 --free-tier-only
```

Use the latest GA name as a Terraform pattern:

```hcl
variable "ami_name_prefix" {
  description = "Prefix for the RHEL AMI name search"
  type        = string
  default     = "RHEL-10.1.0_HVM_GA-*"
}
```

Or pin directly:

```hcl
variable "ami_id" {
  description = "Explicit AMI id override"
  type        = string
  default     = "ami-09232a2cda00a54c3"
}
```

Later, your instance uses:

```hcl
ami = var.ami_id != "" ? var.ami_id : data.aws_ami.rhel.id
```

### 2.2. SUSE SLES, free tier eligible

List free tier eligible SUSE images:

```bash
./ami_lookup.sh --platform suse --region eu-north-1 --free-tier-only --limit 10
```

This lists images such as:

```text
ami-047284102275b63ad  true  SUSE Linux  2025-11-04T19:40:36.000Z  suse-sles-16-0-v20251104-hvm-ssd-x86_64
```

From there you can define:

```hcl
variable "ami_name_patterns" {
  type        = list(string)
  description = "Patterns for SUSE SLES AMIs"
  default     = ["suse-sles-16-0-v*-hvm-ssd-x86_64"]
}
```

and use `ami_name_patterns` in your `data "aws_ami"` filter.

### 2.3. Red Hat plus SUSE, for baseline or hardening

To get all Red Hat and SUSE platform images for a region:

```bash
./ami_lookup.sh --type rhel_suse --region eu-north-1 --limit 20
```

This is useful when building a shortlist of base images to harden or scan.

---

## 3. Integration idea: Terraform friendly outputs

A common pattern is to use the script to discover the latest image, then feed it into Terraform via `*.tfvars`.

For example:

1. Run:

   ```bash
   ./ami_lookup.sh --type rhel10 --region eu-north-1 --free-tier-only
   ```

2. Take the newest `ImageId` from the output JSON:

   ```json
   "ImageId": "ami-09232a2cda00a54c3"
   ```

3. Put it in `terraform.tfvars`:

   ```hcl
   ami_id = "ami-09232a2cda00a54c3"
   ```

4. Keep `ami_name_prefix` as a fallback or baseline, not as the single source of truth.

This gives you a very clear workflow:

* Script discovers candidates.
* Human chooses and pins.
* Terraform uses that decision deterministically.

---

## 4. Summary

`ami_lookup.sh` is your small but capable AMI catalog assistant:

* Knows how to talk in terms of:

  * Types like `rhel10` and `rhel_suse`
  * Platforms like `rhel`, `suse`, `ubuntu`
  * Free tier only or full catalog
* Writes compact JSON that is easy to reuse.
* Makes picking Terraform AMIs significantly less guessy.

Use it whenever you need a clean, auditable path from:

> "I clicked something nice in the AWS console"

to

> "Here is the exact AMI pattern or id that Terraform will use."
