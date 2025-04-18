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
        pkgs = nixpkgs.legacyPackages.${system};
        # [ "1.2.9" "1.2.10"]
        supportedVersions = builtins.filter (line: line != "") (
          lib.splitString "\n" (builtins.readFile ./supported_versions)
        );
        # "1.2.10": { derivation }
        bunFromVersion = pkgs.callPackage ./lib/bun-from-version.nix {};
        # { 1_2_9 = { derivation }; 1_2_10 = { derivation }; }
        bunByVersion = lib.listToAttrs (
          map (version: {
            name = lib.replaceStrings ["."] ["_"] version;
            value = bunFromVersion version;
          })
          supportedVersions
        );
      in {
        lib = {
          # "1.2.10": { derivation }
          inherit bunFromVersion;
          # [ "1.2.9" "1.2.10"]
          bunVersions = supportedVersions;
        };
        # default = { derivation };
        packages.default = self.packages.${system}.bunVersions.latest;
        # bunVersions = { 1_2_10 = { derivation }; latest = { derivation }; };
        packages.bunVersions =
          bunByVersion
          // {
            latest = bunFromVersion (lib.last supportedVersions);
          };

        formatter = pkgs.alejandra;
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.bun
            pkgs.alejandra

            pkgs.jq
            pkgs.curl
            pkgs.bash
            pkgs.coreutils
          ];
        };
      }
    );
}
