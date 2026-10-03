#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

ssh_dir="$HOME/.ssh"
[ ! -L "$ssh_dir" ] || die "$ssh_dir is a symlink; inspect it before configuring permissions."
[ ! -e "$ssh_dir" ] || [ -d "$ssh_dir" ] || die "$ssh_dir is not a directory."
log 'Configuring SSH directory and permissions.'
run mkdir -p "$ssh_dir"
run chmod 700 "$ssh_dir"

# Do not follow symlinks, modify other owners' files, or assume key filenames.
# Keep all regular files private; public keys and known_hosts may be world-readable.
if [ -d "$ssh_dir" ]; then
  while IFS= read -r -d '' directory; do
    run chmod 700 "$directory"
  done < <(find "$ssh_dir" -type d -user "$(id -un)" -print0)
  while IFS= read -r -d '' file; do
    case "$file" in
      *.pub|*/known_hosts|*/known_hosts.old) run chmod 644 "$file" ;;
      *) run chmod 600 "$file" ;;
    esac
  done < <(find "$ssh_dir" -type f -user "$(id -un)" -print0)
fi

for managed_file in "$ssh_dir/config" "$ssh_dir/dotenv.conf"; do
  [ ! -L "$managed_file" ] || die "$managed_file is a symlink; inspect it before modifying."
done
run cp "$REPO_DIR/ssh/defaults.conf" "$ssh_dir/dotenv.conf"
run chmod 600 "$ssh_dir/dotenv.conf"
include_line='    Include ~/.ssh/dotenv.conf'
if ! grep -Fqx "$include_line" "$ssh_dir/config" 2>/dev/null; then
  if [ "$DRY_RUN" = 1 ]; then
    log "[dry-run] Append managed SSH defaults to $ssh_dir/config"
  else
    # SSH uses the first value obtained. Append defaults after personal rules.
    printf '\n# Defaults managed by dotenv setup\nHost *\n%s\n' "$include_line" >> "$ssh_dir/config"
  fi
fi
run chmod 600 "$ssh_dir/config"

# Leave existing configuration intact. Keys are created separately when needed.
if [ ! -e "$ssh_dir/config" ] && [ ! -L "$ssh_dir/config" ]; then
  run touch "$ssh_dir/config"
  run chmod 600 "$ssh_dir/config"
fi
