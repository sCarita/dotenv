#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/scripts/lib.sh"

usage() {
  cat <<'USAGE'
Usage: ./setup.sh [--dry-run] [--only ssh|shell|angry-ip-scanner|homebrew|apps|development|git|vim|vscode|extensions]

With no options, configure SSH and zsh, install Angry IP Scanner,
install Homebrew and Brewfile packages, and configure development tools, Git,
Vim colors, and VS Code with extensions.
--dry-run prints intended changes without modifying the machine.
--only runs one setup step.
USAGE
}

step=all
while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --only)
      [ "$#" -ge 2 ] || die '--only needs a step name.'
      step="$2"; shift 2
      case "$step" in ssh|shell|angry-ip-scanner|homebrew|apps|development|git|vim|vscode|extensions) ;; *) die "Unknown step: $step" ;; esac
      ;;
    -h|--help) usage; exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done
export DRY_RUN
require_macos

for task_step in ssh shell angry-ip-scanner homebrew apps development git vim vscode extensions; do
  if [ "$step" = all ] || [ "$step" = "$task_step" ]; then
    /bin/bash "$REPO_DIR/scripts/$task_step.sh"
  fi
done
log 'Setup finished. Open a new terminal to load shell changes.'
