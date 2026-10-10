#!/usr/bin/env bash
set -euo pipefail

required_dart="3.13.0"
flutter_dir="${HOME}/flutter"
repo_root="$(cd "$(dirname "$0")/.." && pwd)"

current_dart="0.0.0"
if [[ -x "${flutter_dir}/bin/dart" ]]; then
  current_dart="$("${flutter_dir}/bin/dart" --version 2>&1 | awk '{print $4}')"
fi

if [[ "$(printf '%s\n' "$required_dart" "$current_dart" | sort -V | head -n1)" != "$required_dart" ]]; then
  archive_url="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.47.0-stable.tar.xz"
  temporary_dir="$(mktemp -d)"
  trap 'rm -rf "$temporary_dir"' EXIT

  curl --fail --location --silent --show-error "$archive_url" \
    | tar -xJ -C "$temporary_dir"
  rm -rf "$flutter_dir"
  mv "${temporary_dir}/flutter" "$flutter_dir"
  trap - EXIT
  rm -rf "$temporary_dir"
fi

sudo tee /usr/local/bin/flutter >/dev/null <<'EOF'
#!/usr/bin/env bash
exec "${HOME}/flutter/bin/flutter" "$@"
EOF
sudo tee /usr/local/bin/dart >/dev/null <<'EOF'
#!/usr/bin/env bash
exec "${HOME}/flutter/bin/dart" "$@"
EOF
sudo chmod 755 /usr/local/bin/flutter /usr/local/bin/dart

if [[ ! -x /usr/local/bin/node ]]; then
  node_bin=""
  if [[ -d "${HOME}/.nvm/versions/node" ]]; then
    node_bin="$(find "${HOME}/.nvm/versions/node" -mindepth 2 -maxdepth 2 -type f -name node | sort -V | tail -n1)"
  fi
  if [[ -n "${node_bin}" && -x "${node_bin}" ]]; then
    node_dir="$(dirname "${node_bin}")"
    sudo ln -sfn "${node_bin}" /usr/local/bin/node
    sudo ln -sfn "${node_dir}/npm" /usr/local/bin/npm
    sudo ln -sfn "${node_dir}/npx" /usr/local/bin/npx
  else
    node_version="22.21.0"
    node_archive="$(mktemp -d)"
    curl --fail --location --silent --show-error \
      "https://nodejs.org/dist/v${node_version}/node-v${node_version}-linux-x64.tar.xz" \
      | tar -xJ -C "${node_archive}"
    sudo cp -a "${node_archive}/node-v${node_version}-linux-x64/." /usr/local/
    rm -rf "${node_archive}"
  fi
fi

export PATH="/usr/local/bin:${flutter_dir}/bin:${PATH}"
flutter config --no-analytics --enable-web >/dev/null
flutter precache --web
(
  cd "${repo_root}"
  flutter pub get
)

if [[ -f "${repo_root}/cloudflare/guess-the-pokemon/package-lock.json" ]]; then
  (
    cd "${repo_root}/cloudflare/guess-the-pokemon"
    npm ci
  )
fi

flutter --version
node --version
npm --version
