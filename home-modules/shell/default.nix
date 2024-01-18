#  Shell
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ home.nix
#   └─ ./modules
#       └─ ./shell
#           └─ default.nix *
#               └─ ...
#
{
  imports = [
    ./git.nix
    ./zsh.nix
    ./starship.nix
    ./yazi
  ];
}
