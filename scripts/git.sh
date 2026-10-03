#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
require_macos

log 'Installing shared Git defaults.'
config_dir="$HOME/.config/dotenv/git"
run mkdir -p "$config_dir"
run cp "$REPO_DIR/git/config" "$config_dir/config"
run cp "$REPO_DIR/git/ignore" "$config_dir/ignore"
if ! git config --global --get-all include.path 2>/dev/null | grep -Fqx "$config_dir/config"; then
  run git config --global --add include.path "$config_dir/config"
fi
# Preserve an existing personal global ignore file.
if ! git config --global --includes --get core.excludesFile >/dev/null 2>&1; then
  run git config --global core.excludesFile "$config_dir/ignore"
else
  log 'Preserving the existing global Git ignore file.'
fi
if ! git config --global --includes --get user.name >/dev/null 2>&1 ||
   ! git config --global --includes --get user.email >/dev/null 2>&1; then
  log 'Git identity is not fully configured. Set user.name and user.email locally; see README.md.'
fi
