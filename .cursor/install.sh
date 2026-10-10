#!/usr/bin/env bash
set -euo pipefail

required_dart="3.13.0"
flutter_bin="$(readlink -f "$(command -v flutter)")"
flutter_dir="$(cd "$(dirname "$flutter_bin")/.." && pwd)"
current_dart="$("${flutter_dir}/bin/dart" --version 2>&1 | awk '{print $4}')"

if [[ "$(printf '%s\n' "$required_dart" "$current_dart" | sort -V | head -n1)" != "$required_dart" ]]; then
  archive_url="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.47.0-stable.tar.xz"
  temporary_dir="$(mktemp -d)"
  trap 'rm -rf "$temporary_dir"' EXIT

  curl --fail --location --silent --show-error "$archive_url" \
    | tar -xJ -C "$temporary_dir"
  rm -rf "$flutter_dir"
  mv "${temporary_dir}/flutter" "$flutter_dir"
fi

"${flutter_dir}/bin/flutter" pub get
