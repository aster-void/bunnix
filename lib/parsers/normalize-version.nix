# Supported format:
# - exact: 1.2.8
# - with `_` instead of .: 1_2_8
# - with `v` prefix: v1.2.8
# - with `bun@` prefix: bun@1.2.8
# - with spaces, for whatever reason: " 1.2.8 "
# - without patch: 1.2 (will default to latest of the minor)
# - without minor: 1 (will default to latest of the major)
# Not supported format:
# - ^1.2.8
# - ~1.2.8
{
  lib,
  supportedVersions,
  startsWith,
}: version: let
  normalized = lib.replaceStrings ["_" "bun" "@" "v" " " "\t" "\n" "\r"] ["." "" "" "" "" "" "" ""] version;
  len = builtins.length (lib.splitVersion normalized);
in
  if normalized == "latest"
  then lib.last supportedVersions
  else if len > 3
  then throw "Invalid version format: got \"" ++ version ++ "\""
  else if len == 3
  then normalized
  else lib.last (lib.filter (v: startsWith (normalized + ".") v) supportedVersions)
