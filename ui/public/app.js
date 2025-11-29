// ui/public/app.js
const FLAG_KEYS = [
  "enable_stack",
  "enable_instances",
  "enable_alb",
  "enable_dns",
  "enable_storage",
  "enable_iam",
  "enable_vpc",
];

async function loadFlags() {
  const status = document.getElementById("status");
  status.textContent = "Loading current flags...";
  status.className = "status info";

  try {
    const res = await fetch("/api/features");
    const data = await res.json();

    FLAG_KEYS.forEach((key) => {
      const el = document.getElementById(key);
      if (el) {
        el.checked = Boolean(data[key]);
      }
    });

    status.textContent = "Flags loaded from features.auto.tfvars";
    status.className = "status ok";
  } catch (err) {
    console.error(err);
    status.textContent = "Failed to load flags";
    status.className = "status error";
  }
}

async function saveFlags(event) {
  event.preventDefault();
  const status = document.getElementById("status");
  status.textContent = "Saving flags and pushing to Git...";
  status.className = "status info";

  const payload = {};
  FLAG_KEYS.forEach((key) => {
    const el = document.getElementById(key);
    if (el) {
      payload[key] = el.checked;
    }
  });

  try {
    const res = await fetch("/api/features", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });

    if (!res.ok) {
      throw new Error("API error");
    }

    const data = await res.json();
    console.log("Updated flags:", data.flags);

    status.textContent =
      "Flags saved and commit_gh invoked. HCP Terraform will pick up the change.";
    status.className = "status ok";
  } catch (err) {
    console.error(err);
    status.textContent = "Failed to save flags or push to Git";
    status.className = "status error";
  }
}

document.addEventListener("DOMContentLoaded", () => {
  const form = document.getElementById("flags-form");
  form.addEventListener("submit", saveFlags);
  loadFlags();
});
