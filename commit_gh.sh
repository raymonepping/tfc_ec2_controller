#!/usr/bin/env bash
set -euo pipefail

MSG="${1:-"chore: update feature flags"}"

# If the Brew-installed commit_gh exists, delegate to it
if command -v commit_gh >/dev/null 2>&1; then
  exec commit_gh "$MSG"
fi

echo "[commit_gh.sh] Brew commit_gh not found, using lightweight git fallback..."

# Basic safety: ensure we are inside a git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[commit_gh.sh] Error: not inside a git repository" >&2
  exit 1
fi

# Stage feature flags file
if [ -f "features.auto.tfvars" ]; then
  git add features.auto.tfvars
fi

# Only commit if there is something to commit
if git diff --cached --quiet; then
  echo "[commit_gh.sh] No changes to commit"
  exit 0
fi

git commit -m "$MSG"

# Optional: push current branch
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
git push origin "$CURRENT_BRANCH"

echo "[commit_gh.sh] Commit and push completed on branch ${CURRENT_BRANCH}"