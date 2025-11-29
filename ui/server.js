// ui/server.js
//
// Minimal control panel for Terraform feature flags.
// - Reads and writes features.auto.tfvars in the repo root
// - Exposes a JSON API for the browser UI
// - Calls commit_gh so HCP Terraform picks up changes

const express = require("express");
const path = require("path");
const fs = require("fs/promises");
const { exec } = require("child_process");

const app = express();
const PORT = process.env.PORT || 4000;

// Repo and features file locations (adjust if needed)
const REPO_ROOT = path.join(__dirname, "..");
const FEATURES_FILE = path.join(REPO_ROOT, "features.auto.tfvars");

// Flags that we control from the UI
const FLAG_KEYS = [
  "enable_stack",
  "enable_instances",
  "enable_alb",
  "enable_dns",
  "enable_storage",
  "enable_iam",
  "enable_vpc",
];

// Defaults when no features.auto.tfvars exists yet
const DEFAULT_FLAGS = {
  enable_stack: true,
  enable_instances: true,
  enable_alb: true,
  enable_dns: true,
  enable_storage: true,
  enable_iam: true,
  enable_vpc: false,
};

app.use(express.json());
app.use(express.static(path.join(__dirname, "public")));

// Helper to run shell commands and capture stdout/stderr
function runCommand(cmd, options = {}) {
  return new Promise((resolve, reject) => {
    exec(cmd, options, (error, stdout, stderr) => {
      if (error) {
        return reject({ error, stdout, stderr });
      }
      resolve({ stdout, stderr });
    });
  });
}

// Read current flags from features.auto.tfvars (or fall back to defaults)
async function readFlags() {
  try {
    const content = await fs.readFile(FEATURES_FILE, "utf8");
    const flags = { ...DEFAULT_FLAGS };

    for (const key of FLAG_KEYS) {
      const regex = new RegExp(`^${key}\\s*=\\s*(true|false)`, "m");
      const match = content.match(regex);
      if (match) {
        flags[key] = match[1] === "true";
      }
    }

    return flags;
  } catch {
    // If the file does not exist yet, start from defaults
    return { ...DEFAULT_FLAGS };
  }
}

// Write flags back to features.auto.tfvars
async function writeFlags(flags) {
  const lines = [
    "##############################################################################",
    "# Feature toggles - managed by the Terraform EC2 Control Panel UI",
    "#",
    "# This file is meant to be changed from the Node UI while demoing.",
    "##############################################################################",
    "",
  ];

  for (const key of FLAG_KEYS) {
    const value = flags[key] ? "true" : "false";
    lines.push(`${key} = ${value}`);
  }

  lines.push("");
  await fs.writeFile(FEATURES_FILE, lines.join("\n"), "utf8");
}

// Call commit_gh in the repo root to push the updated flags
async function commitAndPush() {
  // commit_gh lives in your PATH, so we just call it
  const { stdout, stderr } = await runCommand("commit_gh", {
    cwd: REPO_ROOT,
  });

  if (stderr && stderr.trim().length > 0) {
    console.error(stderr);
  }
  console.log(stdout);

  return { stdout, stderr };
}

// Optional metadata: branch and last commit for display in the UI
async function getGitMeta() {
  try {
    const branchRes = await runCommand("git rev-parse --abbrev-ref HEAD", {
      cwd: REPO_ROOT,
    });
    const commitRes = await runCommand(
      "git log -1 --pretty=format:%h%x20%an%x20%ad%x20%s",
      { cwd: REPO_ROOT }
    );

    return {
      branch: branchRes.stdout.trim(),
      last_commit: commitRes.stdout.trim(),
      features_file: FEATURES_FILE,
    };
  } catch (err) {
    console.error("Failed to read git meta:", err);
    return {
      branch: "unknown",
      last_commit: "unknown",
      features_file: FEATURES_FILE,
    };
  }
}

// API: get current flags
app.get("/api/features", async (req, res) => {
  try {
    const flags = await readFlags();
    res.json(flags);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to read feature flags" });
  }
});

// API: get git/meta information for display
app.get("/api/meta", async (req, res) => {
  try {
    const meta = await getGitMeta();
    res.json(meta);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to read repository metadata" });
  }
});

// API: update flags and trigger commit_gh
app.post("/api/features", async (req, res) => {
  try {
    const body = req.body || {};
    const current = await readFlags();
    const next = { ...current };

    for (const key of FLAG_KEYS) {
      if (Object.prototype.hasOwnProperty.call(body, key)) {
        next[key] = Boolean(body[key]);
      }
    }

    await writeFlags(next);
    const gitResult = await commitAndPush();

    res.json({
      ok: true,
      flags: next,
      git: {
        stdout: gitResult.stdout,
        stderr: gitResult.stderr,
      },
    });
  } catch (err) {
    console.error("Failed to update flags or push to Git:", err);
    res.status(500).json({ error: "Failed to update flags or push to Git" });
  }
});

app.listen(PORT, () => {
  console.log(`Terraform EC2 Control Panel listening on http://localhost:${PORT}`);
});