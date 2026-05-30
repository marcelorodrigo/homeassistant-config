#!/bin/sh
set -e

# Ensure SSH key has correct permissions
chmod 600 /root/.ssh/id_ed25519

export GIT_SSH_COMMAND="ssh -i /root/.ssh/id_ed25519 -o StrictHostKeyChecking=no"

# Reset any local changes that would block fast-forward
git -C /config fetch origin

# Abort if local branch has diverged (not just behind)
LOCAL=$(git -C /config rev-parse HEAD)
REMOTE=$(git -C /config rev-parse FETCH_HEAD)
BASE=$(git -C /config merge-base HEAD FETCH_HEAD)

if [ "$LOCAL" = "$REMOTE" ]; then
  echo "Already up to date."
  exit 0
fi

if [ "$LOCAL" != "$BASE" ]; then
  echo "ERROR: Local commits exist that are not on origin. Manual intervention required." >&2
  git -C /config log --oneline HEAD ^FETCH_HEAD >&2
  exit 1
fi

git -C /config pull --ff-only
