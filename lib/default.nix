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
  fromVersion = callPackage ./bun-from-version.nix {};
  # { v1_2_9 = { derivation }; v1_2_10 = { derivation }; }
  byVersion = lib.listToAttrs (
    map (version: {
      name = "v" + (lib.replaceStrings ["."] ["_"] version);
      value = fromVersion version;
    })
    supportedVersions
  );

  # (cat ./.bun-version) -> "1.2.10"
  parseBunVersion = callPackage ./parsers/parse-bun-version-file.nix {inherit normalizeVersion;};
  # reads from "packageManager" field.
  parsePackageJson = callPackage ./parsers/parse-package-json.nix {inherit normalizeVersion;};
  parseToolVersions = callPackage ./parsers/parse-asdf-tool-version.nix {inherit startsWith normalizeVersion;};

  # (cat ./.bun-version) -> { <derivation> }
  fromBunVersion = file: fromVersion (parseBunVersion file);
  fromPackageJson = file: fromVersion (parsePackageJson file);
  fromToolVersions = file: fromVersion (parseToolVersions file);

  # ./.bun-version -> { <derivation> }
  fromBunVersionFile = path: (fromBunVersion (builtins.readFile path));
  fromPackageJsonFile = path: (fromPackageJson (builtins.readFile path));
  fromToolVersionsFile = path: (fromToolVersions (builtins.readFile path));
in {
  inherit
    # common
    supportedVersions
    normalizeVersion
    fromVersion
    byVersion
    # file parsers
    parseBunVersion
    fromBunVersion
    fromBunVersionFile
    parsePackageJson
    fromPackageJson
    fromPackageJsonFile
    parseToolVersions
    fromToolVersions
    fromToolVersionsFile
    ;
}
