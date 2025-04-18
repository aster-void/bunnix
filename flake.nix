{
  description = "Use latest bun with flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        inherit (pkgs) lib;
        # debugging
        pkgs = nixpkgs.legacyPackages.${system};
        supportedVersions = builtins.filter (line: line != "") (lib.splitString "\n" (builtins.readFile ./supported-versions));
        bunFromVersion = pkgs.callPackage ./bun-from-version.nix {}; # todo
        bunVersions =
          lib.genAttrs supportedVersions bunFromVersion;
      in {
        lib = {
          inherit bunFromVersion bunVersions;
        };
        packages.default =
          self.packages.${system}.bunVersions.latest;
        packages.bunVersions =
          bunVersions
          // {
            latest = bunFromVersion (lib.last supportedVersions);
          };

        devShells.default = pkgs.mkShell {packages = [pkgs.bun];};
      }
    );
}
