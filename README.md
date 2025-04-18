# Bunnix

## What's this?

A Toolkit to manage bun in nix.

## Features + Roadmap

Features:
- Run every bun version since 1.2.0

Roadmap:
- Run every bun version since 1.0.0
- Bun package build helper

## How to use

It's this easy.

```sh
# run latest bun
nix run github:aster-void/bunnix
# run specific version of bun
nxi run github:aster-void/bunnix#bunVersions.1_2_10
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
