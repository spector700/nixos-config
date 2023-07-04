#
#  Hyprland configuration
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ ./<host>
#   │       └─ default.nix
#   └─ ./modules
#       └─ ./desktop
#           └─ ./hyprland
#               └─ default.nix *
#

{ pkgs, system, hyprland, user, ... }:
let 
  exec = "exec Hyprland";
in {
  imports = [ ../../programs/waybar.nix ];

  environment = {
     # start from tty
     #extraInit = ''
     # if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
     #   ${exec}
     # fi
    # '';

     variables = {
      XDG_CURRENT_DESKTOP="Hyprland";
      XDG_SESSION_TYPE="wayland";
      XDG_SESSION_DESKTOP="Hyprland";
     };
     sessionVariables = {
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      __GL_GSYNC_ALLOWED = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR="1";
      GDK_BACKEND = "wayland";
      WLR_NO_HARDWARE_CURSORS = "1";
      MOZ_ENABLE_WAYLAND = "1";
      GDK_SCALE = "2";
      XCURSOR_SIZE = "32";
     };

     systemPackages = with pkgs; [
      grim
      slurp
      swappy
      swaybg
      swaylock
      wl-clipboard
      wlr-randr
    ];
  }; 

  security.pam.services.swaylock = {
      text = ''
      auth include login
      '';
    };
  programs.hyprland = {
    enable = true;
    };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "Hyprland";
        user = "${user}";
      };
     };
   };

  programs.dconf.enable = true;
  xdg.portal = {
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
   };

  nixpkgs.overlays = [    # Waybar with experimental features
    (final: prev: {
      waybar = hyprland.packages.${system}.waybar-hyprland;
    })
  ];
}
