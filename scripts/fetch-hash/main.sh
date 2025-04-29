#!/usr/bin/env bash
set -euo pipefail

#
# FLAGS:
# ENV VARS:
# - SKIP_VERIFY?: "true" | "false" - skips verification step (, which runs `bun test`) (default: false)
# - NO_REGISTRY?: "true" | "false" - skips writing to supported_versions, as well as stopping version duplication check (default: false)
#

printerr() {
    Red='\033[0;31m'   # Red
    Color_Off='\033[0m' # Text Reset
    echo -e "${Red}error${Color_Off}:" "$@" >&2
}
error() {
    printerr "$@"
    exit 1
}

cd "$(dirname -- "$0")"
if [[ "$1" =~ \d+\.\d+\.\d+ ]]; then
  error 'Please provide version in this format: 1.2.10'
fi
version=$1
if ! "${NO_REGISTRY:=false}"; then
  if grep --silent "^$version$" ../../lib/supported_versions; then
    error 'Version already installed. If you want to still run this, run again with NO_REGISTRY=true'
  fi
fi

mkdir -p ../../tmp/fetch-hash
(
  cd ../../tmp/fetch-hash
  
  nix_platforms=(
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-darwin"
    "x86_64-linux"
  )
  OUT_PATH="../../lib/version-info/v${version}.nix"
  echo '{hashes = {' > "$OUT_PATH"
  for NIX_PLAT in "${nix_platforms[@]}"; do
    case $NIX_PLAT in
      "aarch64-darwin")
        URI_PLAT="darwin-aarch64";;
      "aarch64-linux")
        URI_PLAT="linux-aarch64";;
      "x86_64-darwin")
        URI_PLAT="darwin-x64-baseline";;
      "x86_64-linux")
        URI_PLAT="linux-x64";;
    esac

    BUN_URI="https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-$URI_PLAT.zip"
    curl --fail --location --progress-bar --output "$NIX_PLAT.tmp.zip" "$BUN_URI" ||
        printerr "Failed to download bun from \"$BUN_URI\""
    {
      echo -n "$NIX_PLAT = \"";
      if [ -f "$NIX_PLAT.tmp.zip" ]; then
        nix hash file "$NIX_PLAT.tmp.zip" | tr --delete '\n';
      else
        echo "Sorry, couldn't fetch this resource"
      fi
      echo '";'
    } >> "$OUT_PATH"
    rm "$NIX_PLAT.tmp.zip" || true
  done
  
  echo '  };
    builder-version = "v1";
  }' >> "$OUT_PATH"
  
  alejandra "$OUT_PATH" 1>&2
)
rmdir ../../tmp/fetch-hash ../../tmp

# writing to reg
if ! $NO_REGISTRY; then
  echo "$version" >> ../../lib/supported_versions
  sort --version-sort ../../lib/supported_versions -o ../../lib/supported_versions
fi

# verify
(
  if ! "${SKIP_VERIFY:-false}"; then
    cd ../..
  
    git add -N "./lib/version-info/v${version}.nix"
    
    nix run ".#v${version//./_}" test 1>&2
  fi
)
