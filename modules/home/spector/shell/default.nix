{ inputs, ... }:
{
  imports = [
    ./tools
    ./yazi
    ./git.nix
    ./ssh.nix
    ./starship.nix
    ./zsh.nix

    inputs.nix-index-database.hmModules.nix-index
    { programs.nix-index-database.comma.enable = true; }
  ];
}
