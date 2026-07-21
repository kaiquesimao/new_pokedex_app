#!/usr/bin/env bash
# Bump app version, commit, tag, and push (triggers Android release).
#
# Usage:
#   ./scripts/release.sh patch|minor|major [--dry-run]
#
# Build number (+N) always increments by 1.
set -euo pipefail

bump="${1:-}"
dry_run=0
if [[ "${2:-}" == "--dry-run" ]]; then
  dry_run=1
elif [[ -n "${2:-}" ]]; then
  echo "Unknown option: $2 (expected --dry-run)" >&2
  exit 1
fi

if [[ "$bump" != "patch" && "$bump" != "minor" && "$bump" != "major" ]]; then
  echo "Usage: $0 patch|minor|major [--dry-run]" >&2
  exit 1
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$branch" == "HEAD" ]]; then
  echo "Detached HEAD - check out a branch before releasing." >&2
  exit 1
fi

if [[ "$dry_run" -eq 0 ]]; then
  if [[ -n "$(git status --porcelain)" ]]; then
    echo "Working tree is not clean. Commit or stash changes first." >&2
    git status --porcelain >&2
    exit 1
  fi
fi

line="$(grep -E '^version:' pubspec.yaml | head -n1)"
if [[ ! "$line" =~ ^version:[[:space:]]*([0-9]+)\.([0-9]+)\.([0-9]+)\+([0-9]+)[[:space:]]*$ ]]; then
  echo "Unexpected version format: $line (expected x.y.z+build)" >&2
  exit 1
fi

major="${BASH_REMATCH[1]}"
minor="${BASH_REMATCH[2]}"
patch="${BASH_REMATCH[3]}"
build="${BASH_REMATCH[4]}"
old_version="${major}.${minor}.${patch}+${build}"

build=$((build + 1))
case "$bump" in
  major) major=$((major + 1)); minor=0; patch=0 ;;
  minor) minor=$((minor + 1)); patch=0 ;;
  patch) patch=$((patch + 1)) ;;
esac

new_version="${major}.${minor}.${patch}+${build}"
name_only="${major}.${minor}.${patch}"
tag="v${name_only}"

if [[ "$dry_run" -eq 0 ]] && git rev-parse -q --verify "refs/tags/${tag}" >/dev/null; then
  echo "Tag ${tag} already exists." >&2
  exit 1
fi

echo "Branch:  ${branch}"
echo "Bump:    ${bump}"
echo "Version: ${old_version} -> ${new_version}"
echo "Tag:     ${tag}"

if [[ "$dry_run" -eq 1 ]]; then
  echo "Dry run - no changes made."
  exit 0
fi

tmp="$(mktemp)"
# Portable in-place replace (GNU/BSD sed differ); write via temp file.
if ! awk -v ver="$new_version" '
  BEGIN { replaced = 0 }
  /^version:[[:space:]]*[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+[[:space:]]*$/ && !replaced {
    print "version: " ver
    replaced = 1
    next
  }
  { print }
  END { exit replaced ? 0 : 1 }
' pubspec.yaml >"$tmp"; then
  rm -f "$tmp"
  echo "Failed to replace version line in pubspec.yaml" >&2
  exit 1
fi
mv "$tmp" pubspec.yaml

git add pubspec.yaml
git commit -m "chore: bump version to ${new_version}"
git tag "$tag"

echo "Pushing ${branch} and ${tag}..."
git push -u origin HEAD
git push origin "$tag"

cat <<EOF

Done. Release Android should start for ${tag}.
Track: internal (default). Monitor: Actions → Release Android
EOF
