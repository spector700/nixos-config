{ pkgs, inputs, ... }:
{
  default = pkgs.mkShell {

    imports = [ inputs.treefmt-nix.flakeModule ];
    NIX_CONFIG = "extra-experimental-features = nix-command flakes repl-flake";

    nativeBuildInputs = with pkgs; [
      # sops stuff
      sops
      ssh-to-age
      age
    ];
  };
}
