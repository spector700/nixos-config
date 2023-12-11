#
#  General Home-manager configuration
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ home.nix *
#   └─ ./modules
#       ├─ ./editors
#       │   └─ default.nix
#       ├─ ./programs
#       │   └─ default.nix
#       └─ ./services
#           └─ default.nix
#

{ pkgs, user, ... }:

{
  imports =
    (import ../modules/editors) ++
    (import ../modules/programs) ++
    (import ../modules/shell) ++
    (import ../modules/services);

  programs = {
    home-manager.enable = true;
  };

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";


    packages = with pkgs; [
      # Terminal Utils
      tldr
      neofetch

      # Video/Audio
      feh
      mpv
      pavucontrol
      gimp

      # Apps
      armcord
      signal-desktop
      networkmanagerapplet
      nextcloud-client
      obsidian
      anki-bin
      vial

      # File Management
      unzip
      unrar
      xdg-utils
    ];


    file.".config/wallpaper".source = ../modules/themes/wallpaper;

    stateVersion = "23.05";
  };



}
