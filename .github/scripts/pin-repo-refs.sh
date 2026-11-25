#!/usr/bin/env bash
# Rewrites this repository's @master references in workflows and actions to the given ref, so a release only ever uses
# the workflows and actions from that same release.
set -euo pipefail
shopt -s nullglob globstar

ref=$1
repo=${GITHUB_REPOSITORY:?GITHUB_REPOSITORY must be set}
files=(.github/workflows/*.y*ml actions/**/action.y*ml)

sed -i -E "s#($repo/[^@\"' ]+)@master#\1@$ref#gI" "${files[@]}"

if grep -niE "$repo/[^@\"' ]+@master" "${files[@]}"; then
  echo "::error::References to $repo@master were left unpinned"
  exit 1
fi
