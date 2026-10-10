#!/usr/bin/env bash
set -euo pipefail

required_dart="3.13.0"
current_dart="$(dart --version 2>&1 | awk '{print $4}')"

if [[ "$(printf '%s\n' "$required_dart" "$current_dart" | sort -V | head -n1)" != "$required_dart" ]]; then
  flutter upgrade --force
fi

flutter pub get
