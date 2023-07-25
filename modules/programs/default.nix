#
#  Apps
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ home.nix
#   └─ ./modules
#       └─ ./programs
#           └─ default.nix *
#               └─ ...
#

[
  ./kitty.nix
  ./eww
  ./rofi
  ./anyrun.nix
  ./spicetify.nix
  #./waybar.nix
  #./games.nix
]
# Waybar.nix is pulled from modules/desktop/..
# Games.nix is pulled from desktop/default.nix
