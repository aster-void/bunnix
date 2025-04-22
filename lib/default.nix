{
  lib,
  callPackage,
}: let
  # [ "1.2.9" "1.2.10"]
  supportedVersions = builtins.filter (line: line != "") (
    lib.splitString "\n" (builtins.readFile ./supported_versions)
  );
  startsWith = substr: full: lib.strings.commonPrefixLength full substr == builtins.stringLength substr;
  normalizeVersion = callPackage ./parsers/normalize-version.nix {inherit supportedVersions startsWith;};

  # "1.2.10": { derivation }
  bunFromVersion = callPackage ./bun-from-version.nix {};
  # { v1_2_9 = { derivation }; v1_2_10 = { derivation }; }
  bunByVersion = lib.listToAttrs (
    map (version: {
      name = "v" + (lib.replaceStrings ["."] ["_"] version);
      value = bunFromVersion version;
    })
    supportedVersions
  );

  # (cat ./.bun-version) -> "1.2.10"
  parseBunVersionFile = callPackage ./parsers/parse-bun-version-file.nix {inherit normalizeVersion;};
  # (cat ./package.json) -> "1.2.10"
  # reads from "packageManager" field.
  parsePackageJson = callPackage ./parsers/parse-package-json.nix {inherit normalizeVersion;};
  # (cat .tool-versions) -> "1.2.10"
  parseAsdfToolVersions = callPackage ./parsers/parse-asdf-tool-version.nix {inherit startsWith normalizeVersion;};
in {
  inherit supportedVersions normalizeVersion bunFromVersion bunByVersion parseBunVersionFile parsePackageJson parseAsdfToolVersions;
  # ./.bun-version -> { <derivation> }
  fromBunVersionFile = path: bunFromVersion (parseBunVersionFile (builtins.readFile path));
  # ./package.json -> { <derivation> }
  fromPackageJson = path: bunFromVersion (parsePackageJson (builtins.readFile path));
  # ./.tool-versions -> { <derivation> }
  fromToolVersions = path: bunFromVersion (parseAsdfToolVersions (builtins.readFile path));
}
