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
    (import ../modules/services);

  programs = {
    home-manager.enable = true;
  };

  home = {
      username = "${user}";
      homeDirectory = "/home/${user}";

      packages = with pkgs; [
        # Terminal Utils
        btop
        tldr

        # Video/Audio
        feh
        mpv
        pavucontrol

        # Apps
        brave
        spotify
        discord

        # File Management
        okular
        unzip
        
      ];



      file.".config/wallpaper".source = ../modules/themes/wallpaper;

      pointerCursor = {
          gtk.enable = true;
          name = "Dracula-cursors";
          package = pkgs.dracula-theme;
          size = 16;
        };
      stateVersion = "23.05";
    };

    gtk = { 
      enable = true;
      theme = {
        name = "Dracula";
        package = pkgs.dracula-theme;
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
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
      };

      gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
      };
    };
}
