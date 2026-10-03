#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
require_macos

settings_dir="$HOME/Library/Application Support/Code/User"
settings="$settings_dir/settings.json"
log 'Configuring VS Code with the Dark Modern theme.'
if [ "$DRY_RUN" = 1 ]; then
  log "[dry-run] Merge $REPO_DIR/vscode/settings.json into $settings, backing up existing settings if changed."
  exit 0
fi

if command -v jq >/dev/null 2>&1; then
  jq_bin="$(command -v jq)"
elif brew_bin="$(find_brew)" && [ -x "$(dirname "$brew_bin")/jq" ]; then
  jq_bin="$(dirname "$brew_bin")/jq"
else
  die 'jq is required. Run ./setup.sh --only apps first.'
fi

existing=/dev/null
if [ -e "$settings" ]; then
  "$jq_bin" -e 'type == "object"' "$settings" >/dev/null 2>&1 ||
    die 'Existing VS Code settings must be a JSON object. Comments/trailing commas need manual editing; the original file has been left unchanged.'
  existing="$settings"
fi
mkdir -p "$settings_dir"
temporary="$(mktemp "$settings_dir/.dotenv-settings.XXXXXX")"
trap 'rm -f "$temporary"' EXIT
"$jq_bin" -s 'reduce .[] as $item ({}; . * $item)' "$existing" "$REPO_DIR/vscode/settings.json" > "$temporary"
if [ -e "$settings" ] && cmp -s "$settings" "$temporary"; then
  log 'VS Code settings are already configured.'
  exit 0
fi
if [ -e "$settings" ]; then
  backup="$(mktemp "$settings_dir/settings.json.dotenv-backup.XXXXXX")"
  cp -p "$settings" "$backup"
  log "Saved previous settings to $backup."
fi
mv "$temporary" "$settings"
log 'VS Code theme configured. Reopen VS Code if the change is not visible yet.'
