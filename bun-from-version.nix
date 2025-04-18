{callPackage}: version: let
  builders = import ./lib/builders;
  info = import ./version-info/v${version}.nix;
in
  callPackage builders.${info.builder-version} {} {
    inherit version info;
  }
