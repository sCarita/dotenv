#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
require_macos

if brew_bin="$(find_brew)"; then
  log "Homebrew already exists at $brew_bin."
else
  log 'Installing Homebrew using its official installer (administrator access may be requested).'
  if [ "$DRY_RUN" = 1 ]; then
    log '[dry-run] Download and run https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh'
    case "$(uname -m)" in
      arm64) brew_bin=/opt/homebrew/bin/brew ;;
      *) brew_bin=/usr/local/bin/brew ;;
    esac
  else
    installer="$(mktemp -t dotenv-homebrew)"
    trap 'rm -f "$installer"' EXIT
    curl --fail --silent --show-error --location \
      https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$installer"
    /bin/bash "$installer"
    brew_bin="$(find_brew)" || die 'Homebrew installation did not produce a brew executable.'
  fi
fi

profile="$HOME/.zprofile"
shellenv_line="eval \"\$($brew_bin shellenv)\""
if ! grep -Fqx "$shellenv_line" "$profile" 2>/dev/null; then
  if [ "$DRY_RUN" = 1 ]; then
    log "[dry-run] Append $shellenv_line to $profile"
  else
    printf '\n# Homebrew (managed by dotenv setup)\n%s\n' "$shellenv_line" >> "$profile"
  fi
fi
