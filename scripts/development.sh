#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
require_macos

if [ "$DRY_RUN" = 1 ]; then
  log '[dry-run] Install uv-managed Python 3.12, upstream nvm 0.40.8, Node 24, Corepack/Yarn, and Firebase CLI.'
  log '[dry-run] Merge Docker plugin discovery and create Colima defaults if missing; no services will start.'
  exit 0
fi
brew_bin="$(find_brew)" || die 'Install Homebrew and Brewfile packages first.'
eval "$("$brew_bin" shellenv)"
command -v uv >/dev/null || die 'uv is missing. Run ./setup.sh --only apps.'
uv python install 3.12

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  installer="$(mktemp -t dotenv-nvm)"
  trap 'rm -f "$installer"' EXIT
  curl --fail --silent --show-error --location --retry 3 \
    https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh -o "$installer"
  expected=48a0eee9a60e07422dce0eb5774754c83889570ca1ee2566c516acbe8af03a9e
  [ "$(shasum -a 256 "$installer" | awk '{print $1}')" = "$expected" ] || die 'nvm installer checksum mismatch.'
  PROFILE=/dev/null METHOD=script NVM_INSTALL_VERSION=v0.40.8 /bin/bash "$installer"
fi
# Upstream nvm is not compatible with nounset.
set +u
source "$NVM_DIR/nvm.sh" --no-use
nvm install 24
[ -f "$NVM_DIR/alias/default" ] || nvm alias default 24
nvm use 24
if ! command -v corepack >/dev/null; then
  npm install -g corepack
fi
corepack enable
corepack install --global yarn@stable
if ! npm list -g firebase-tools --depth=0 >/dev/null 2>&1; then
  npm install -g firebase-tools
fi
set -u

# Retain Docker authentication, contexts, and any existing plugin directories.
docker_dir="${DOCKER_CONFIG:-$HOME/.docker}"
docker_settings="$docker_dir/config.json"
[ ! -L "$docker_settings" ] || die 'Docker config is a symlink; inspect it before modifying.'
mkdir -p "$docker_dir"
existing=/dev/null
if [ -e "$docker_settings" ]; then
  jq -e 'type == "object" and ((.cliPluginsExtraDirs // []) | type == "array")' "$docker_settings" >/dev/null || die 'Docker config is not a valid object with an array of plugin directories.'
  existing="$docker_settings"
fi
temporary="$(mktemp "$docker_dir/.dotenv-config.XXXXXX")"
trap 'rm -f "${installer:-}" "$temporary"' EXIT
jq -s --arg plugins "$("$brew_bin" --prefix)/lib/docker/cli-plugins" \
  '(.[0] // {}) | .cliPluginsExtraDirs = ((.cliPluginsExtraDirs // []) | if index($plugins) then . else . + [$plugins] end)' "$existing" > "$temporary"
if [ -e "$docker_settings" ] && cmp -s "$temporary" "$docker_settings"; then
  log 'Docker plugin discovery is already configured.'
else
  if [ -e "$docker_settings" ]; then
    backup="$(mktemp "$docker_dir/config.json.dotenv-backup.XXXXXX")"
    cp -p "$docker_settings" "$backup"
  fi
  mv "$temporary" "$docker_settings"
fi

colima_dir="${COLIMA_HOME:-$HOME/.colima}/default"
if [ ! -e "$colima_dir/colima.yaml" ]; then
  mkdir -p "$colima_dir"
  cp "$REPO_DIR/colima/default.yaml" "$colima_dir/colima.yaml"
fi
log 'Development tools configured. Start containers explicitly with colima start.'
