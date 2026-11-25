#!/usr/bin/env bash
# Copies files, directories or glob patterns (one per line in $RELEASE_PATHS) into
# the directory given as the first argument. Each directory is zipped separately.
set -euo pipefail

shopt -s nullglob globstar
IFS= # Expand globs without splitting paths that contain spaces

mkdir -p "$1"
artifacts_dir=$(realpath "$1")

while IFS=$' \t\r' read -r pattern; do
  [[ -z "$pattern" ]] && continue

  matches=($pattern)
  # nullglob drops unmatched globs, but keeps a literal path even if it doesn't exist
  if [[ ! -e "${matches[0]-}" ]]; then
    echo "::warning::No files found for additional release path '$pattern'"
    continue
  fi

  for match in "${matches[@]}"; do
    name=$(basename "$match")
    asset=$name
    [[ -d "$match" ]] && asset+=".zip"

    # Release assets share one flat namespace
    if [[ -e "$artifacts_dir/$asset" ]]; then
      echo "::error::Multiple release files are named '$asset' (from '$match')"
      exit 1
    fi

    if [[ -d "$match" ]]; then
      (cd "$(dirname "$match")" && zip -qr "$artifacts_dir/$asset" "$name")
    else
      cp "$match" "$artifacts_dir/$asset"
    fi
  done
done <<< "$RELEASE_PATHS"
