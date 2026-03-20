#!/usr/bin/env bash
# Deploy wallet.hashpool.dev (ehash branch) to the hashpool VPS.
#
# Usage:
#   ./scripts/deploy.sh
#
# Override defaults with env vars:
#   VPS_HOST=1.2.3.4 VPS_USER=root ./scripts/deploy.sh

set -euo pipefail

# ── Configuration ────────────────────────────────────────────────────────────
VPS_HOST="${VPS_HOST:-80.71.235.186}"
VPS_USER="${VPS_USER:-root}"
VPS_DIR="${VPS_DIR:-/opt/cashu.me}"
GIT_BRANCH="${GIT_BRANCH:-ehash}"
SSH_TARGET="${VPS_USER}@${VPS_HOST}"
SSH_OPTS="-o BatchMode=yes -o ConnectTimeout=15 -o StrictHostKeyChecking=accept-new"
# ─────────────────────────────────────────────────────────────────────────────

echo "==> Deploying branch '${GIT_BRANCH}' to ${SSH_TARGET}:${VPS_DIR}"

# Push local commits to the remote so the VPS can pull them.
echo "==> Pushing local commits..."
git push origin "${GIT_BRANCH}"

# SSH into the VPS and rebuild.
ssh ${SSH_OPTS} "${SSH_TARGET}" bash -s <<EOF
set -euo pipefail

echo "--- Entering project directory"
cd "${VPS_DIR}"

echo "--- Fetching latest code (branch: ${GIT_BRANCH})"
git config --global --add safe.directory "${VPS_DIR}"
git fetch origin
git checkout "${GIT_BRANCH}"
git reset --hard "origin/${GIT_BRANCH}"

echo "--- Installing dependencies"
npm install

echo "--- Building SPA"
npx quasar build -m spa

echo "--- Deploy complete"
ls dist/spa/
EOF

echo "==> Done. wallet.hashpool.dev should be live shortly."
