// ui/server.js
//
// Minimal control panel for Terraform feature flags.
// - Reads and writes features.auto.tfvars in the repo root
// - Exposes a JSON API for the browser UI
// - Calls commit_gh when /api/apply is used so HCP Terraform picks up changes

const express = require("express");
const path = require("path");
const fs = require("fs/promises");
const { exec } = require("child_process");

const app = express();
const PORT = process.env.PORT || 4000;

// Repo and features file locations
const REPO_ROOT = path.join(__dirname, "..");
const FEATURES_FILE = path.join(REPO_ROOT, "features.auto.tfvars");

// Boolean flags managed by the UI
const BOOL_FLAG_KEYS = [
  "enable_stack",
  "enable_instances",
  "enable_alb",
  "enable_dns",
  "enable_storage",
  "enable_iam",
  "enable_vpc",
  "data_volume_encrypted",
];

const INSTANCE_COUNT_KEY = "instance_count";
const OS_TYPE_KEY = "os_type";

// Defaults when no features.auto.tfvars exists yet
const DEFAULT_FLAGS = {
  enable_stack: true,
  enable_instances: true,
  enable_alb: true,
  enable_dns: true,
  enable_storage: true,
  enable_iam: true,
  enable_vpc: false,
  data_volume_encrypted: false,
  instance_count: 2,
  os_type: "rhel10",
};

app.use(express.json());
app.use(express.static(path.join(__dirname, "public")));

// Helper to run shell commands
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

// Lightweight helper to detect if a command exists in PATH
async function hasCommand(cmd) {
  try {
    await runCommand(`command -v ${cmd}`);
    return true;
  } catch {
    return false;
  }
}

// Read current flags from features.auto.tfvars or fall back to defaults
async function readFlags() {
  try {
    const content = await fs.readFile(FEATURES_FILE, "utf8");
    const flags = { ...DEFAULT_FLAGS };

    // booleans
    for (const key of BOOL_FLAG_KEYS) {
      const regex = new RegExp(`^${key}\\s*=\\s*(true|false)`, "m");
      const match = content.match(regex);
      if (match) {
        flags[key] = match[1] === "true";
      }
    }

    // instance_count
    const countMatch = content.match(
      new RegExp(`^${INSTANCE_COUNT_KEY}\\s*=\\s*([0-9]+)`, "m"),
    );
    if (countMatch) {
      flags.instance_count = Number(countMatch[1]);
    }

    // os_type
    const osMatch = content.match(
      new RegExp(`^${OS_TYPE_KEY}\\s*=\\s*"(.*?)"`, "m"),
    );
    if (osMatch) {
      flags.os_type = osMatch[1];
    }

    return flags;
  } catch {
    return { ...DEFAULT_FLAGS };
  }
}

// Write flags back to features.auto.tfvars
async function writeFlags(flags) {
  const lines = [
    "##############################################################################",
    "# Feature toggles - managed by Node UI",
    "#",
    "# Do not edit by hand during demos. Use the UI instead.",
    "##############################################################################",
    "",
  ];

  for (const key of BOOL_FLAG_KEYS) {
    const value = flags[key] ? "true" : "false";
    lines.push(`${key} = ${value}`);
  }

  lines.push("");
  lines.push("# Non-boolean controls");
  lines.push(`${INSTANCE_COUNT_KEY} = ${flags.instance_count}`);
  lines.push(`${OS_TYPE_KEY} = "${flags.os_type}"`);
  lines.push("");

  await fs.writeFile(FEATURES_FILE, lines.join("\n"), "utf8");
}

// Call commit_gh in the repo root, with a fallback to ./commit_gh.sh
async function commitAndPush() {
  // First attempt: Brew commit_gh from PATH
  try {
    const result = await runCommand("commit_gh", {
      cwd: REPO_ROOT,
    });

    if (result.stderr && result.stderr.trim().length > 0) {
      console.error(result.stderr);
    }
    console.log(result.stdout);

    return result;
  } catch (primaryError) {
    console.warn(
      "[server] commit_gh from PATH failed, falling back to ./commit_gh.sh",
      primaryError,
    );
  }

  // Fallback: repo local commit_gh.sh
  const fallbackCmd = process.platform === "win32"
    ? "bash ./commit_gh.sh"
    : "./commit_gh.sh";

  const { stdout, stderr } = await runCommand(fallbackCmd, {
    cwd: REPO_ROOT,
  });

  if (stderr && stderr.trim().length > 0) {
    console.error(stderr);
  }
  console.log(stdout);

  return { stdout, stderr };
}

// Metadata for display
async function getGitMeta() {
  try {
    const branchRes = await runCommand("git rev-parse --abbrev-ref HEAD", {
      cwd: REPO_ROOT,
    });
    const commitRes = await runCommand(
      "git log -1 --pretty=format:%h%x20%an%x20%ad%x20%s",
      { cwd: REPO_ROOT },
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

// API: git/meta info
app.get("/api/meta", async (req, res) => {
  try {
    const meta = await getGitMeta();
    res.json(meta);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to read repository metadata" });
  }
});

// API: update flags only (no git push)
app.post("/api/features", async (req, res) => {
  try {
    const body = req.body || {};
    const current = await readFlags();
    const next = { ...current };

    // booleans
    for (const key of BOOL_FLAG_KEYS) {
      if (Object.prototype.hasOwnProperty.call(body, key)) {
        next[key] = Boolean(body[key]);
      }
    }

    // instance_count, clamped 0..10
    if (Object.prototype.hasOwnProperty.call(body, INSTANCE_COUNT_KEY)) {
      const n = Number(body[INSTANCE_COUNT_KEY]);
      if (!Number.isNaN(n)) {
        next.instance_count = Math.min(Math.max(Math.trunc(n), 0), 10);
      }
    }

    // os_type
    if (Object.prototype.hasOwnProperty.call(body, OS_TYPE_KEY)) {
      const v = String(body[OS_TYPE_KEY] || "").toLowerCase();
      next.os_type = v === "rhel9" ? "rhel9" : "rhel10";
    }

    await writeFlags(next);

    res.json({
      ok: true,
      flags: next,
    });
  } catch (err) {
    console.error("Failed to update flags:", err);
    res.status(500).json({ error: "Failed to update feature flags" });
  }
});

// API: apply changes by running commit_gh once
app.post("/api/apply", async (req, res) => {
  try {
    const gitResult = await commitAndPush();
    res.json({
      ok: true,
      git: {
        stdout: gitResult.stdout,
        stderr: gitResult.stderr,
      },
    });
  } catch (err) {
    console.error("Failed to push changes to Git:", err);
    res.status(500).json({ error: "Failed to push changes to Git" });
  }
});

app.listen(PORT, () => {
  console.log(
    `Terraform EC2 Control Panel listening on http://localhost:${PORT}`,
  );
});