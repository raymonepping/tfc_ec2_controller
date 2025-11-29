# Terraform EC2 Control Panel UI

This folder contains a small Node.js based control panel for the modular EC2 stack.

The UI does not run Terraform itself.  
It writes feature flags into `features.auto.tfvars` in the repository root and then calls `commit_gh`.  
Your HCP Terraform workspace is responsible for detecting the Git change and running a plan and apply.

---

## What it controls

The UI manages these boolean flags:

- `enable_stack`  
- `enable_instances`  
- `enable_alb`  
- `enable_dns`  
- `enable_storage`  
- `enable_iam`  
- `enable_vpc`

These map directly to the feature variables in `features.tf` and drive:

- Whether the whole stack is considered active
- Whether EC2 instances are created
- Whether the Application Load Balancer and Route53 record exist
- Whether extra data EBS volumes are attached per instance
- Whether an IAM role and instance profile are attached
- Whether a managed VPC from `modules/vpc` is used instead of an existing VPC

The current values are stored in `features.auto.tfvars` at the root of the repository.

---

## Requirements

- Node.js 18 or later
- `commit_gh` in your `PATH`  
  This script is expected to stage changes, commit, and push to `origin/main`.

The UI assumes it is started from the `ui` folder with the repository root being one level up.

---

## Getting started

From the repository root:

```bash
cd ui
npm install
node server.js
```

Then open:

http://localhost:4000


You will see:

A set of toggles grouped into three sections:

Core stack

Networking and entry

Storage and identity

A status line that shows whether the last update succeeded

Metadata about the Git branch, last commit and the location of features.auto.tfvars

Whenever you flip a switch:

The UI sends the new flag values to /api/features

server.js writes features.auto.tfvars

server.js calls commit_gh in the repo root

Your HCP Terraform workspace, configured with VCS integration, picks up the commit

API overview

The server exposes a very small JSON API:

GET /api/features
Returns the current boolean feature flags.

POST /api/features
Accepts a JSON body with any subset of the flags and updates features.auto.tfvars.
After writing, it calls commit_gh in the repository root.

GET /api/meta
Returns repository metadata for the UI:

branch

last_commit

features_file

The static frontend is served from ui/public.

Notes

The UI is intentionally minimal. It is not an approval system and it does not replace Terraform Cloud UX.

Treat commit_gh as the gatekeeper.
If you want an approval step, add it to that script.

For workshops, you can keep the Terraform code untouched and let participants flip switches with this UI.


### Root `README.md` snippet

Add a short section near the bottom of your main `README.md`:

```markdown
## Optional: Terraform EC2 Control Panel UI

This repository includes an optional Node.js based control panel in `./ui` that lets you flip the Terraform feature flags from a browser.

The UI:

- Reads and writes `features.auto.tfvars`
- Manages the feature flags in `features.tf` (stack, instances, ALB, DNS, storage, IAM, VPC)
- Calls `commit_gh` so that your HCP Terraform workspace can pick up changes

To use it:

```bash
cd ui
npm install
node server.js
```

Then open http://localhost:4000 and toggle the switches.
No Terraform CLI is invoked directly from the UI. All changes flow through Git and your existing HCP Terraform workflow.
