{ inputs, ... }:
{
  imports = [
    ./tools
    ./yazi
    ./zellij
    ./git.nix
    ./gpg.nix
    ./kitty.nix
    ./nix-search-tv.nix
    ./ssh.nix
    ./starship.nix
    ./zsh.nix

    inputs.nix-index-database.homeModules.nix-index
    { programs.nix-index-database.comma.enable = true; }
  ];
}
