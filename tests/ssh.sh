#!/bin/bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_home="$(mktemp -d -t dotenv-ssh-test)"
trap 'rm -rf "$test_home"' EXIT

check_mode() {
  actual="$(stat -f '%Lp' "$1")"
  [ "$actual" = "$2" ] || { printf '%s: expected %s, got %s\n' "$1" "$2" "$actual" >&2; exit 1; }
}

# Dry run on a fresh home must not create anything.
HOME="$test_home" DRY_RUN=1 /bin/bash "$repo_dir/scripts/ssh.sh"
[ ! -e "$test_home/.ssh" ]
HOME="$test_home" /bin/bash "$repo_dir/scripts/ssh.sh"
check_mode "$test_home/.ssh" 700
check_mode "$test_home/.ssh/config" 600

printf 'Host example\n' > "$test_home/.ssh/config"
printf 'test fixture\n' > "$test_home/.ssh/custom-private-key"
touch "$test_home/.ssh/key.pub" "$test_home/.ssh/known_hosts" "$test_home/.ssh/authorized_keys"
mkdir "$test_home/.ssh/nested"
touch "$test_home/.ssh/nested/private-key" "$test_home/outside-file"
chmod 777 "$test_home/.ssh" "$test_home/.ssh/nested"
chmod 666 "$test_home/.ssh/config" "$test_home/.ssh/custom-private-key" "$test_home/outside-file"
ln -s "$test_home/outside-file" "$test_home/.ssh/link"

HOME="$test_home" /bin/bash "$repo_dir/scripts/ssh.sh"
HOME="$test_home" /bin/bash "$repo_dir/scripts/ssh.sh"
check_mode "$test_home/.ssh" 700
check_mode "$test_home/.ssh/nested" 700
check_mode "$test_home/.ssh/config" 600
check_mode "$test_home/.ssh/custom-private-key" 600
check_mode "$test_home/.ssh/nested/private-key" 600
check_mode "$test_home/.ssh/authorized_keys" 600
check_mode "$test_home/.ssh/key.pub" 644
check_mode "$test_home/.ssh/known_hosts" 644
check_mode "$test_home/outside-file" 666
[ "$(head -n 1 "$test_home/.ssh/config")" = 'Host example' ]
[ "$(grep -Fc 'Include ~/.ssh/dotenv.conf' "$test_home/.ssh/config")" = 1 ]
check_mode "$test_home/.ssh/dotenv.conf" 600

mkdir "$test_home/symlink-home" "$test_home/target"
ln -s "$test_home/target" "$test_home/symlink-home/.ssh"
if HOME="$test_home/symlink-home" /bin/bash "$repo_dir/scripts/ssh.sh"; then
  printf 'Expected symlink directory rejection.\n' >&2
  exit 1
fi
printf 'SSH checks passed.\n'
