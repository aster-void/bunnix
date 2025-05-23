{
  description = "Use latest bun with flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        bunnixLib = pkgs.callPackage ./lib {};
      in {
        lib = bunnixLib;
        # { default = { derivation }; latest = { derivation }; v1_2_10 = { derivation }; };
        packages =
          bunnixLib.byVersion
          // {
            default = bunnixLib.fromVersion (pkgs.lib.last bunnixLib.supportedVersions);
            latest = bunnixLib.fromVersion (pkgs.lib.last bunnixLib.supportedVersions);
          };

        checks = {
          unitTest = pkgs.callPackage ./tests.nix {bunnixLib = bunnixLib;};
        };
        devShells.default = pkgs.mkShell {
          packages = [
            # self.packages.${system}.latest
            pkgs.bun
            pkgs.alejandra
            pkgs.biome

            pkgs.jq
            pkgs.curl
            pkgs.bash
            pkgs.coreutils
          ];
        };
      }
    );
}
