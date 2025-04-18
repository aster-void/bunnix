/*
source: github:nixos/nixpkgs/pkgs/by-name/bu/bun/package.nix at 2025-04-18 1:30 PM JST

Copyright (c) 2003-2025 Eelco Dolstra and the Nixpkgs/NixOS contributors

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  unzip,
  installShellFiles,
  makeWrapper,
  openssl,
  writeShellScript,
  curl,
  jq,
  common-updater-scripts,
  cctools,
  darwin,
  rcodesign,
}: {
  version,
  info,
}: let
  inherit (info) hashes;
in
  stdenvNoCC.mkDerivation rec {
    inherit version;
    pname = "bun";

    src =
      passthru.sources.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");

    sourceRoot =
      {
        aarch64-darwin = "bun-darwin-aarch64";
        x86_64-darwin = "bun-darwin-x64-baseline";
      }
    .${
        stdenvNoCC.hostPlatform.system
      } or null;

    strictDeps = true;
    nativeBuildInputs =
      [
        unzip
        installShellFiles
        makeWrapper
      ]
      ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [autoPatchelfHook];
    buildInputs = [openssl];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      install -Dm 755 ./bun $out/bin/bun
      ln -s $out/bin/bun $out/bin/bunx

      runHook postInstall
    '';

    postPhases = ["postPatchelf"];
    postPatchelf =
      lib.optionalString stdenvNoCC.hostPlatform.isDarwin ''
        '${lib.getExe' cctools "${cctools.targetPrefix}install_name_tool"}' $out/bin/bun \
          -change /usr/lib/libicucore.A.dylib '${lib.getLib darwin.ICU}/lib/libicucore.A.dylib'
        '${lib.getExe rcodesign}' sign --code-signature-flags linker-signed $out/bin/bun
      ''
      # We currently cannot generate completions for x86_64-darwin because bun requires avx support to run, which is:
      # 1. Not currently supported by the version of Rosetta on our aarch64 builders
      # 2. Is not correctly detected even on macOS 15+, where it is available through Rosetta
      #
      # The baseline builds are no longer an option because they too now require avx support.
      + lib.optionalString
      (
        stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform
        && !(stdenvNoCC.hostPlatform.isDarwin && stdenvNoCC.hostPlatform.isx86_64)
      )
      ''
        completions_dir=$(mktemp -d)

        SHELL="bash" $out/bin/bun completions $completions_dir
        SHELL="zsh" $out/bin/bun completions $completions_dir
        SHELL="fish" $out/bin/bun completions $completions_dir

        installShellCompletion --name bun \
          --bash $completions_dir/bun.completion.bash \
          --zsh $completions_dir/_bun \
          --fish $completions_dir/bun.fish
      '';

    passthru = {
      sources = {
        "aarch64-darwin" = fetchurl {
          url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-darwin-aarch64.zip";
          hash = hashes.aarch64-darwin;
        };
        "aarch64-linux" = fetchurl {
          url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-aarch64.zip";
          hash = hashes.aarch64-linux;
        };
        "x86_64-darwin" = fetchurl {
          url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-darwin-x64-baseline.zip";
          hash = hashes.x86_64-darwin;
        };
        "x86_64-linux" = fetchurl {
          url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64.zip";
          hash = hashes.x86_64-linux;
        };
      };
      updateScript = writeShellScript "update-bun" ''
        set -o errexit
        export PATH="${
          lib.makeBinPath [
            curl
            jq
            common-updater-scripts
          ]
        }"
        NEW_VERSION=$(curl --silent https://api.github.com/repos/oven-sh/bun/releases/latest | jq '.tag_name | ltrimstr("bun-v")' --raw-output)
        if [[ "${version}" = "$NEW_VERSION" ]]; then
            echo "The new version same as the old version."
            exit 0
        fi
        for platform in ${lib.escapeShellArgs meta.platforms}; do
          update-source-version "bun" "$NEW_VERSION" --ignore-same-version --source-key="sources.$platform"
        done
      '';
    };
    meta = with lib; {
      homepage = "https://bun.sh";
      changelog = "https://bun.sh/blog/bun-v${version}";
      description = "Incredibly fast JavaScript runtime, bundler, transpiler and package manager – all in one";
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      longDescription = ''
        All in one fast & easy-to-use tool. Instead of 1,000 node_modules for development, you only need bun.
      '';
      license = with licenses; [
        mit # bun core
        lgpl21Only # javascriptcore and webkit
      ];
      mainProgram = "bun";
      platforms = builtins.attrNames passthru.sources;
      # Broken for Musl at 2024-01-13, tracking issue:
      # https://github.com/NixOS/nixpkgs/issues/280716
      broken = stdenvNoCC.hostPlatform.isMusl;

      # Hangs when run via Rosetta 2 on Apple Silicon
      hydraPlatforms = lib.lists.remove "x86_64-darwin" lib.platforms.all;
    };
  }
