{callPackage}: version: let
  builders = import ./builders;
  info = import ./version-info/v${version}.nix;
in
  callPackage builders.${info.builder-version} {} {
    inherit version info;
  }
