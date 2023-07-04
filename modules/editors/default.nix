#
#  Editors
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ ./home.nix
#   └─ ./modules
#       └─ ./services
#           └─ default.nix *
#               └─ ...
#

[
  ./neovim/home.nix
  ./vscode/home.nix         #pulled from host/home.nix
]

