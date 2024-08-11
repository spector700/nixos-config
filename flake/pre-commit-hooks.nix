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
    check.enable = true;
    settings = {
      inherit excludes;

      hooks = {
        # for github actions
        actionlint = mkHook "actionlint" { enable = true; };

        luacheck = mkHook "luacheck" { enable = true; };

        detect-private-keys = mkHook "detect-private-keys" { enable = true; };
        trim-trailing-whitespace = mkHook "trim-trailing-whitespace" { enable = true; };
        check-case-conflicts = mkHook "check-case-conflict" { enable = true; };
        check-symlinks = mkHook "check-symlinks" { enable = true; };
        end-of-file-fixer = mkHook "end-of-file-fixer" { enable = true; };

        treefmt = mkHook "treefmt" { enable = true; };
      };
    };
  };
}
