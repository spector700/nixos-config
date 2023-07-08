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
    (import ../modules/programs); #++
    #(import ../modules/services);

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
        name = "Tokyonight-Dark-BL";
        package = pkgs.tokyo-night-gtk;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      font = {
        name = "JetBrains Mono Regular";
      };
    };
}
