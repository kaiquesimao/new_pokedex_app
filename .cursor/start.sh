#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PORT=5000
LOCK="/tmp/pokedata-flutter-web.pid"

if [[ -f "${LOCK}" ]]; then
  old_pid="$(cat "${LOCK}" || true)"
  if [[ -n "${old_pid}" ]] && kill -0 "${old_pid}" 2>/dev/null; then
    echo "Flutter web server already running (pid ${old_pid})."
    exit 0
  fi
fi

if curl -fsS --max-time 2 "http://127.0.0.1:${PORT}" >/dev/null 2>&1; then
  echo "Port ${PORT} already serves HTTP."
  exit 0
fi

echo $$ > "${LOCK}"

export PATH="/usr/local/bin:${HOME}/flutter/bin:${PATH}"
export FLUTTER_SUPPRESS_ANALYTICS=1

exec flutter run -d web-server --web-port "${PORT}" --web-hostname 0.0.0.0
