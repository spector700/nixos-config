{ pkgs, inputs, ... }:
let
  fmt = {
    projectRootFile = "flake.nix";

    programs = {
      # formats .nix files
      nixfmt-rfc-style.enable = true;
      statix.enable = true;

      shellcheck.enable = true;

      shfmt = {
        enable = true;
      };
    };
  };
in
(inputs.treefmt-nix.lib.evalModule pkgs fmt).config.build.wrapper
