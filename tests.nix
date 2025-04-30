{
  lib,
  bunnixLib,
  runCommand,
  writeText,
}: let
  inherit (bunnixLib) normalizeVersion;
  results = lib.runTests {
    testBasic = {
      expr = normalizeVersion "v1_1_1";
      expected = "1.1.1";
    };
    testBunAt = {
      expr = normalizeVersion "bun@1.1.39";
      expected = "1.1.39";
    };
    testMinor = {
      expr = normalizeVersion "v1.1";
      expected = "1.1.45";
    };
    testPackageJsonParsing = {
      expr = bunnixLib.parsePackageJson (builtins.readFile ./samples/package.json);
      expected = "1.2.7";
    };
    testBunVersionParsing = {
      expr = bunnixLib.parseBunVersion (builtins.readFile ./samples/.bun-version);
      expected = "1.2.6";
    };
    testAsdfToolVersionsParsing = {
      expr = bunnixLib.parseToolVersions (builtins.readFile ./samples/.tool-versions);
      expected = "1.2.5";
    };
  };
in
  runCommand "ut" {} ''
    mkdir $out
    ${
      if results != []
      then ''
        echo '${builtins.toJSON results}'
        echo "failed test. see '${
          writeText "errors.json" (builtins.toJSON results)
        }'"
        exit 1
      ''
      else ''
        echo "all tests passed!"
        exit 0
      ''
    }
  ''
