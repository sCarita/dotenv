#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
require_macos

code_bin='/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code'
if [ "$DRY_RUN" != 1 ]; then
  [ -x "$code_bin" ] || die 'Install VS Code with the apps step first.'
  installed="$("$code_bin" --list-extensions)"
fi
while IFS= read -r extension || [ -n "$extension" ]; do
  [ -n "$extension" ] || continue
  if [ "$DRY_RUN" != 1 ] && printf '%s\n' "$installed" | grep -Fixq "$extension"; then
    log "VS Code extension already installed: $extension"
  else
    run "$code_bin" --install-extension "$extension"
  fi
done < "$REPO_DIR/vscode/extensions.txt"
