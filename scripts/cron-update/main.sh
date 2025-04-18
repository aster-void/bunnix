#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname -- "$0")"

printlog() {
  echo -e "$@" >&2
}

NEW_VERSION=$(curl --silent https://api.github.com/repos/oven-sh/bun/releases/latest | jq '.tag_name | ltrimstr("bun-v")' --raw-output)

printlog "[update checker] latest bun = v$NEW_VERSION"
if grep --silent "^$NEW_VERSION$" ../../lib/supported_versions ; then
  printlog '[update checker] supported_version is up to date'
  exit 0
fi

../fetch-hash/main.sh "$NEW_VERSION"

printlog -n 'New version is: '
echo "$NEW_VERSION"
