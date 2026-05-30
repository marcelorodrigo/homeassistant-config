#!/bin/sh
set -e
echo "Starting git update process..."

# Ensure SSH key has correct permissions
chmod 600 /data/.ssh/id_ed25519

export GIT_SSH_COMMAND="ssh -i /data/.ssh/id_ed25519 -o StrictHostKeyChecking=no"

echo "Fetching origin..."
git -C /config fetch origin

LOCAL=$(git -C /config rev-parse HEAD)
REMOTE=$(git -C /config rev-parse origin/master)
BASE=$(git -C /config merge-base HEAD origin/master)

echo "LOCAL=$LOCAL"
echo "REMOTE=$REMOTE"
echo "BASE=$BASE"

if [ "$LOCAL" = "$REMOTE" ]; then
  echo "Already up to date."
  exit 0
fi

if [ "$LOCAL" != "$BASE" ]; then
  echo "ERROR: Local commits exist that are not on origin/master. Manual intervention required."
  git -C /config log --oneline HEAD ^origin/master
  exit 1
fi

git -C /config pull --ff-only
echo "Update done."
