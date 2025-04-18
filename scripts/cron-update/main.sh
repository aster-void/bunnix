#!/usr/bin/env bash
set -euo pipefail

#
# ENV VARS
# - AUTO_CHECKOUT?: "true" | "false" = false - automatically switches to new bump/bun-v(version) branch if update is found
# - AUTO_COMMIT?: "true" | "false" = false - automatically commits if update is found. only meant to be used in GitHub Actions.
cd "$(dirname -- "$0")"

NEW_VERSION=$(curl --silent https://api.github.com/repos/oven-sh/bun/releases/latest | jq '.tag_name | ltrimstr("bun-v")' --raw-output)

echo "[update checker] latest bun = v$NEW_VERSION"
if grep --silent "^$NEW_VERSION$" ../../supported_versions ; then
  echo '[update checker] supported_version is up to date'
  exit 0
fi

../fetch-hash/main.sh "$NEW_VERSION" 2>&1

if "${AUTO_CHECKOUT:-false}"; then
  git switch --create "bump/bun-v$NEW_VERSION"
fi
if "${AUTO_COMMIT:-false}"; then
  git add -A
  git -c user.name="github-actions[bot]" -c user.email="41898282+github-actions[bot]@users.noreply.github.com" commit -m "chore: bump bun to v$NEW_VERSION"
fi
