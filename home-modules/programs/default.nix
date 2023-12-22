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
{
  imports = [
    ./kitty.nix
    ./rofi
    ./spicetify.nix
    ./qt.nix
    ./gtk.nix
    ./zathura.nix
    ./lf.nix
    ./xdg.nix
  ];


  programs = {
    firefox.enable = true;
    brave.enable = true;
    vscode = {
      enable = true;
      enableExtensionUpdateCheck = true;
    };
  };
}
