#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
require_macos

# Official release: https://github.com/angryip/ipscan/releases/tag/3.10.0
# SHA-256 values from the release assets' GitHub API digest fields.
version=3.10.0
case "$(uname -m)" in
  arm64)
    archive_name="ipscan-$version-macArm64.zip"
    checksum=4047730a0dd8f8617bdc876d72b55b54b16ad4243c05793cb85bed9c945ec885
    ;;
  x86_64)
    archive_name="ipscan-$version-macX86.zip"
    checksum=0917fdca45ac90d786f3b927275f9a797c089580e3b12218ebd53edfe9e061ae
    ;;
  *) die 'Unsupported CPU architecture for Angry IP Scanner.' ;;
esac

app_name='Angry IP Scanner.app'
for app_dir in /Applications "$HOME/Applications"; do
  [ ! -L "$app_dir/$app_name" ] || die "$app_dir/$app_name is a symlink; inspect it before installing."
  if [ -e "$app_dir/$app_name" ]; then
    log "Angry IP Scanner already exists at $app_dir/$app_name; leaving it unchanged."
    exit 0
  fi
done

if [ -w /Applications ]; then
  app_dir=/Applications
else
  app_dir="$HOME/Applications"
fi
url="https://github.com/angryip/ipscan/releases/download/$version/$archive_name"
log "Installing Angry IP Scanner $version to $app_dir."
if [ "$DRY_RUN" = 1 ]; then
  log "[dry-run] Download $url"
  log "[dry-run] Verify SHA-256: $checksum"
  log "[dry-run] Extract, preserve macOS quarantine, and copy $app_name to $app_dir"
  exit 0
fi

work_dir="$(mktemp -d -t dotenv-ipscan)"
trap 'rm -rf "$work_dir"' EXIT
archive="$work_dir/$archive_name"
curl --fail --silent --show-error --location --retry 3 "$url" -o "$archive"
actual_checksum="$(/usr/bin/shasum -a 256 "$archive" | awk '{print $1}')"
[ "$actual_checksum" = "$checksum" ] || die 'Angry IP Scanner checksum mismatch; nothing installed.'
/usr/bin/ditto -x -k "$archive" "$work_dir/unpacked"
bundle="$work_dir/unpacked/$app_name"
[ -d "$bundle/Contents" ] || die 'The archive does not contain the expected application bundle.'
bundle_version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$bundle/Contents/Info.plist")"
[ "$bundle_version" = "$version" ] || die "Unexpected bundle version: $bundle_version"

# curl does not add Finder's download quarantine. Preserve the first-open check.
printf -v quarantine_time '%x' "$(date +%s)"
/usr/bin/xattr -w com.apple.quarantine "0081;$quarantine_time;dotenv;" "$bundle"
mkdir -p "$app_dir"
/usr/bin/ditto "$bundle" "$app_dir/$app_name"
log "Installed $app_dir/$app_name. macOS may request approval when you first open it."
