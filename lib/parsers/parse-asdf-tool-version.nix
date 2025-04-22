{
  lib,
  startsWith,
  normalizeVersion,
}:
# bun 1.2.3 # with comment
# deno 4.5.6
# nodejs 7.8.9
file: let
  # bun 1.2.3 # with comment
  relevantLines = lib.filter (startsWith "bun ") (lib.splitString "\n" file);
  relevantLine = lib.warnIf ((lib.length relevantLines) > 1) "Warning: multiple lines that start with `bun ` prefix" (lib.elemAt relevantLines 0);
  # bun 1.2.3
  withoutComment = lib.elemAt (lib.splitString "#" relevantLine) 0;
  # 1.2.3
  versionOnly = lib.replaceStrings ["bun" " "] ["" ""] withoutComment;
  normalized =
    # READ <https://asdf-vm.com/manage/configuration.html#tool-versions>
    # versionFirst can be one of:
    # ref:1.0.2-a
    # path:~/src/elixir
    # system
    # 1.0.1
    if startsWith "ref:" versionOnly
    then throw "[bunnix] error: `ref:` is not supported in bunnix. check your .tool-versions"
    else if startsWith "path:" versionOnly
    then throw "[bunnix] error: `path:` is not supported in bunnix. check your .tool-versions"
    else if versionOnly == "system"
    then throw "[bunnix] error: `system` is not supported in bunnix. check your .tool-versions"
    else normalizeVersion versionOnly;
in
  normalized
