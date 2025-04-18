{
  callPackage,
  lib,
}: rawVersion: let
  builders = import ./builders;
  info = import ./version-info/v${version}.nix;
  # format version to match /\d+\.\d+\.\d+/ (= 1.2.10)
  # Expected input:
  # - 1.2.10
  # - v1.2.10
  # - v1_2_10
  version = lib.replaceStrings ["_" "v" " " "\n"] ["." "" "" ""] rawVersion;
in
  callPackage builders.${info.builder-version} {} {
    inherit version info;
  }
