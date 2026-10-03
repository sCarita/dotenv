#!/bin/bash
# Shared helpers; compatible with macOS's bundled Bash 3.2.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN="${DRY_RUN:-0}"

log() { printf '\n%s\n' "$*"; }
die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
run() {
  if [ "$DRY_RUN" = 1 ]; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

require_macos() {
  [ "$(uname -s)" = Darwin ] || die 'This setup currently supports macOS only.'
  [ "$(id -u)" != 0 ] || die 'Run as your regular user, without sudo.'
}

find_brew() {
  if [ -x /opt/homebrew/bin/brew ]; then
    printf '%s\n' /opt/homebrew/bin/brew
  elif [ -x /usr/local/bin/brew ]; then
    printf '%s\n' /usr/local/bin/brew
  elif command -v brew >/dev/null 2>&1; then
    command -v brew
  else
    return 1
  fi
}
