#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
require_macos

log 'Installing packages declared in Brewfile.'
if brew_bin="$(find_brew)"; then
  run "$brew_bin" bundle install --file="$REPO_DIR/Brewfile" --no-upgrade
elif [ "$DRY_RUN" = 1 ]; then
  log "[dry-run] brew bundle install --file=$REPO_DIR/Brewfile --no-upgrade"
else
  die 'Homebrew is missing. Run ./setup.sh --only homebrew first.'
fi
