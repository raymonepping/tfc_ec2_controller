# Terraform EC2 Control Panel UI

This folder contains a small Node.js based control panel for the modular EC2 stack.

The UI does not run Terraform itself.  
It writes feature flags into `features.auto.tfvars` in the repository root and then calls `commit_gh`.  
Your HCP Terraform workspace, through VCS integration, is responsible for detecting the Git change and running plan and apply.

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
- `commit_gh` available in your `PATH`  
  This script is expected to stage changes, commit, and push to `origin/main`.

The UI assumes it is started from the `ui` folder with the repository root one level up.

---

## Getting started

From the repository root:

```bash
cd ui
npm install
node server.js
```

Then open:

```bash
http://localhost:4000
```

⸻

Using the UI

You will see a set of toggles grouped into three sections:
 • Core stack
 • Networking and entry
 • Storage and identity

The page also shows:
 • A status line for the last update
 • Metadata about the Git branch and last commit
 • The location of features.auto.tfvars

Whenever you change a toggle:

 1. The UI sends the new flag values to POST /api/features.
 2. server.js writes features.auto.tfvars.
 3. server.js calls commit_gh in the repository root.
 4. Your HCP Terraform workspace, configured with VCS integration, picks up the commit and runs plan and apply according to its settings.

⸻

API overview

The server exposes a small JSON API.

```bash
GET /api/features
```

Returns the current boolean feature flags:

```json
{
  "enable_stack": true,
  "enable_instances": true,
  "enable_alb": true,
  "enable_dns": true,
  "enable_storage": true,
  "enable_iam": true,
  "enable_vpc": false
}
```

POST /api/features

Accepts a JSON body with any subset of the flags and updates features.auto.tfvars.
After writing the file, it calls commit_gh in the repository root.

Example:

```bash
curl -X POST http://localhost:4000/api/features \
  -H "Content-Type: application/json" \
  -d '{"enable_stack": true, "enable_storage": false}'
```

```bash
GET /api/meta
```

Returns repository metadata for the UI:
 • branch
 • last_commit
 • features_file

The static frontend is served from ui/public.

⸻

Notes
 • The UI is intentionally minimal. It is not an approval system and it does not replace the Terraform Cloud interface.
 • Treat commit_gh as the gatekeeper. If you want an approval step, add it to that script.
 • For workshops you can keep the Terraform code untouched and let participants flip switches with this UI.
