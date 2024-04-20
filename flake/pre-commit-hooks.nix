{ inputs, ... }:
let
  excludes = [
    "flake.lock"
    "r'.+\.age$'"
    "r'.+\.sh$'"
  ];
  mkHook =
    name: prev:
    {
      inherit excludes;
      description = "pre-commit hook for ${name}";
      fail_fast = true; # running hooks if this hook fails
      verbose = true;
    }
    // prev;
in
{
  imports = [ inputs.pre-commit-hooks.flakeModule ];

  perSystem.pre-commit = {
    settings = {
      inherit excludes;

      hooks = {
        # for github actions
        actionlint = mkHook "actionlint" { enable = true; };

        luacheck = mkHook "luacheck" { enable = true; };

        treefmt = mkHook "treefmt" { enable = true; };
      };
    };
  };
}
