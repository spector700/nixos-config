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
    (import ../home-modules/editors/neovim) ++
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
      wget

      # Video/Audio
      mpv
      loupe
      celluloid
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
    ];

    stateVersion = "23.05";
  };



}
