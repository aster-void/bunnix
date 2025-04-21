{
  lib,
  callPackage,
}: let
  # [ "1.2.9" "1.2.10"]
  supportedVersions = builtins.filter (line: line != "") (
    lib.splitString "\n" (builtins.readFile ./supported_versions)
  );
  normalizeVersion = callPackage ./parsers/normalize-version.nix {inherit supportedVersions;};
  # (cat ./.bun-version) -> "1.2.10"
  parseBunVersionFile = callPackage ./parsers/parse-bun-version-file.nix {inherit normalizeVersion;};
  # (cat ./package.json) -> "1.2.10"
  # reads from "packageManager" field.
  parsePackageJson = callPackage ./parsers/parse-package-json.nix {inherit normalizeVersion;};

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
in {
  inherit supportedVersions normalizeVersion bunFromVersion bunByVersion parseBunVersionFile parsePackageJson;
  fromBunVersionFile = file: bunFromVersion (parseBunVersionFile (builtins.readFile file));
  fromPackageJson = file: bunFromVersion (parsePackageJson (builtins.readFile file));
}
