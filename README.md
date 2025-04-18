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

It's this easy.

```sh
# run latest bun
nix run github:aster-void/bunnix
# run specific version of bun
nix run github:aster-void/bunnix#bunVersions.1_2_10
```

In an inpure context of nix, do this:

```nix
let
  bunnix = builtins.fetchFlake "github:aster-void/bunnix";
  system = "x86_64-linux"; # your system
in
# if it's a shell.nix,
pkgs.mkShell {
  packages = [
    bunnix.packages.${system}.default # latest bun
    bunnix.packages.${system}.bunVersions."1_2_10" # specific version
  ];
}
```

If it's a flake, do this:

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
        bunnix.packages.${system}.default
        bunnix.packages.${system}.bunVersions."1_2_10" # specific version
      ];
    };
  };
}
```
### Supported versions

all 1.2.x versions are supported at the time of writing this.
see ./supported_versions for all supported versions.

## Contribution

### Get new version of bun

```sh
bun get 1.2.10
```

### Coding style

formatter = alejandra

### Required packages

- Nix
- Git
- Direnv (optional)
