# Bunnix

## What's this?

A Bun version manager for nix.

## Features + Roadmap

Features:
- Run bun on every patch version since 1.0.0
- Updates faster than nixpkgs

Roadmap:
- Bun package build helper

## How to use

### In shell

It's this easy.

```sh
# run latest bun
nix run github:aster-void/bunnix
# run specific version of bun
nix run github:aster-void/bunnix#v1_2_10
```

### In a nix file

In an inpure context of nix, use `builtins.getFlake`:

```nix
let
  bunnix = builtins.fetchFlake "github:aster-void/bunnix";
  system = "x86_64-linux"; # your system
in
# if it's a shell.nix,
pkgs.mkShell {
  packages = [
    bunnix.packages.${system}.default # latest
  ];
}
```

If it's a flake, add bunnix to `inputs`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    bunnix.url = "github:aster-void/bunnix";
    bunnix.inputs.nixpkgs.follows = "nixpkgs"; # deduplicate nixpkgs
  };

  outputs = {
    nixpkgs,
    bunnix,
    ...
  }: let
      system = "x86_64-linux"; # your system
      pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        bunnix.packages.${system}.default # latest
      ];
    };
  };
}
```

then, you can use bunnix however you like:

```nix
{
  packages = [
    # use latest version of bun
    bunnix.packages.${system}.default
    # specify version of bun in the nix file
    bunnix.packages.${system}.v1_2_10
    # from .bun-version
    (bunnix.lib.${system}.fromBunVersionFile ./.bun-version)
    # from package.json's `"packageManager" field
    (bunnix.lib.${system}.fromPackageJsonFile ./package.json)
    # from asdf's `.tool-versions`
    (bunnix.lib.${system}.fromToolVersionsFile ./.tool-versions)
    # parse some other version lock file manually, then get bun of that version
    (bunnix.lib.${system}.fromVersion "v1.2.10")
  ];
}
```


### Supported versions

all 1.x.x versions are supported at the time of writing this.
see `./lib/supported_versions` for all supported versions.

## Contribution

Any kind of Contribution (bug report, feature request, feature implementation, README enhancement, etc) is welcome.

### Coding style

formatter = alejandra, biome

### Required packages

- Nix
- Direnv (optional)

## Maintainance

GitHub Workflow checks for new version every 3 hours, so you (hopefully) don't need to manually do it.

### Get new version of bun

```sh
bun get 1.2.10
```
