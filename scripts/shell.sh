#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
require_macos

log 'Installing zsh preferences, aliases, colors, and tool integrations.'
config_dir="$HOME/.config/dotenv"
run mkdir -p "$config_dir"
run cp "$REPO_DIR/starship/starship.toml" "$config_dir/starship.toml"

# Respect a custom zsh startup directory and preserve existing configuration.
zsh_dir="${ZDOTDIR:-$HOME}"
zshrc="$zsh_dir/.zshrc"
for config_name in preferences aliases colors development tools; do
  run cp "$REPO_DIR/shell/$config_name.zsh" "$config_dir/$config_name.zsh"
  source_line="[ -r \"\$HOME/.config/dotenv/$config_name.zsh\" ] && source \"\$HOME/.config/dotenv/$config_name.zsh\""
  if ! grep -Fqx "$source_line" "$zshrc" 2>/dev/null; then
    run mkdir -p "$zsh_dir"
    if [ "$DRY_RUN" = 1 ]; then
      log "[dry-run] Append $config_name loading line to $zshrc"
    else
      printf '\n# Terminal %s (managed by dotenv setup)\n%s\n' "$config_name" "$source_line" >> "$zshrc"
    fi
  fi
done
