#!/usr/bin/env bash
# Mirrors this flake repo into /etc/nixos (where nixos-rebuild looks for a
# flake by default) and then applies it.
#
# .git is excluded on purpose: nix flakes silently ignore any file inside a
# git-repo directory that isn't tracked by git, and copying .git along
# without a matching `git add` on the /etc/nixos side would hit exactly that
# footgun on the next new file. Plain (non-git) directories aren't filtered
# at all, so leaving .git out keeps /etc/nixos simple and predictable.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
DEST_DIR="/etc/nixos"
HOST="x1-extreme"

echo "Syncing $REPO_DIR -> $DEST_DIR"
sudo rsync -a --delete \
  --exclude ".git" \
  --exclude "$SCRIPT_NAME" \
  "$REPO_DIR"/ "$DEST_DIR"/

echo "Applying configuration for host '$HOST'"
sudo nixos-rebuild switch --flake "$DEST_DIR#$HOST"
