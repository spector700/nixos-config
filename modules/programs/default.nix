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
  ./rofi
  ./anyrun.nix
  ./spicetify.nix
  ./browser.nix
  ./qt.nix
  ./gtk.nix
  ./vscode.nix
  #./thunar.nix
  #./waybar.nix
  #./games.nix
]
# Waybar.nix is pulled from modules/desktop/..
# Games.nix is pulled from desktop/default.nix
# thunar.nix is pulled from desktop/default.nix
