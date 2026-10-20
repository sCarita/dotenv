#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
require_macos

log 'Installing Vim dark color scheme configuration.'
vim_dir="$HOME/.vim"
vimrc="$HOME/.vimrc"
source_line='source ~/.vim/dotenv.vim'
for managed_path in "$vim_dir/dotenv.vim" "$vimrc"; do
  [ ! -L "$managed_path" ] || die "$managed_path is a symlink; inspect it before modifying."
done
run mkdir -p "$vim_dir"
run cp "$REPO_DIR/vim/config.vim" "$vim_dir/dotenv.vim"
if ! grep -Fqx "$source_line" "$vimrc" 2>/dev/null; then
  if [ "$DRY_RUN" = 1 ]; then
    log "[dry-run] Back up an existing $vimrc and append the theme loading line."
  else
    if [ -e "$vimrc" ]; then
      backup="$(mktemp "$HOME/.vimrc.dotenv-backup.XXXXXX")"
      cp -p "$vimrc" "$backup"
      log "Saved previous Vim configuration to $backup."
    fi
    printf '\n" Vim colors (managed by dotenv setup)\n%s\n' "$source_line" >> "$vimrc"
  fi
fi
log 'Vim configuration installed. Reopen Vim or run :source ~/.vimrc to load it.'
