// ui/server.js
const express = require("express");
const path = require("path");
const fs = require("fs/promises");
const { exec } = require("child_process");

const app = express();
const PORT = process.env.PORT || 4000;

// Adjust if you run the server from somewhere else
const REPO_ROOT = path.join(__dirname, "..");
const FEATURES_FILE = path.join(REPO_ROOT, "features.auto.tfvars");

const FLAG_KEYS = [
  "enable_stack",
  "enable_instances",
  "enable_alb",
  "enable_dns",
  "enable_storage",
  "enable_iam",
  "enable_vpc",
];

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
  } catch (err) {
    // If the file does not exist yet, return defaults
    return { ...DEFAULT_FLAGS };
  }
}

async function writeFlags(flags) {
  const lines = [
    "##############################################################################",
    "# Feature toggles - managed by Node UI",
    "#",
    "# Do not edit by hand during demos. Use the UI instead.",
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

function commitAndPush() {
  return new Promise((resolve, reject) => {
    const cmd = "./commit_gh";
    exec("commit_gh", { cwd: REPO_ROOT }, (error, stdout, stderr) => {
      if (error) {
        console.error("commit_gh failed:", error);
        console.error(stderr);
        return res.status(500).json({ error: "commit_gh failed" });
      }

      console.log(stdout);
      return res.json({ ok: true });
    });
  });
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
    await commitAndPush();

    res.json({ ok: true, flags: next });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to update flags or push to Git" });
  }
});

app.listen(PORT, () => {
  console.log(`Terraform toggle UI listening on http://localhost:${PORT}`);
});
