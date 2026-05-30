#!/bin/sh
export GIT_SSH_COMMAND="ssh -i /root/.ssh/id_ed25519 -o StrictHostKeyChecking=no"
git -C /config pull --ff-only
