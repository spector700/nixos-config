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

      # Video/Audio
      feh
      mpv
      pavucontrol
      gimp

      # Apps
      brave
      webcord-vencord
      signal-desktop

      # File Management
      okular
      unzip

    ];



    file.".config/wallpaper".source = ../modules/themes/wallpaper;

    stateVersion = "23.05";

    pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      name = "macOS-BigSur";
      package = pkgs.apple-cursor;
      size = 20;
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Compact-Blue-dark";
      package = pkgs.catppuccin-gtk.override {
        size = "compact";
        accents = [ "blue" ];
        #tweaks = [ "rimless" ];
        variant = "mocha";
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "JetBrains Mono Regular";
      size = 12;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  nix.settings = {
    builders-use-substitutes = true;
    substituters = [
      "https://nix-gaming.cachix.org"
      "https://anyrun.cachix.org"
    ];

    trusted-public-keys = [
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
    ];
  };
}
