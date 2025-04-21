{normalizeVersion}: file:
normalizeVersion (builtins.fromJSON file).packageManager or (throw "[bunnix] Error: package.json doesn't seem to have \"packageManager\" field")
