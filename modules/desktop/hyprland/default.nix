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
  imports = [ ../../programs/waybar ];

  environment = {
     # start from tty
     #extraInit = ''
     # if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
     #   ${exec}
     # fi
    # '';

     variables = {
     };
     sessionVariables = {
      XDG_CURRENT_DESKTOP="Hyprland";
      XDG_SESSION_TYPE="wayland";
      XDG_SESSION_DESKTOP="Hyprland";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      __GL_GSYNC_ALLOWED = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR="1";
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      #GDK_SCALE = "2";
      #XCURSOR_SIZE = "32";
     };

     systemPackages = with pkgs; [
      grim
      slurp
      swappy
      swaybg
      swaylock
      wl-clipboard
      wlr-randr
      xorg.xprop
    ];
  }; 

  fonts.enableDefaultFonts = true;
  programs.dconf.enable = true;

  security.pam.services.swaylock = {
      text = ''
      auth include login
      '';
    };
   #programs.hyprland = {
   #  enable = true;
   #  xwayland.enable = true;
   #  xwayland.hidpi = true;
   #  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "Hyprland";
        user = "${user}";
      };
     };
   };

  xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-hyprland ];
   };

  nixpkgs.overlays = [    # Waybar with experimental features
    (final: prev: {
      waybar = hyprland.packages.${system}.waybar-hyprland;
    })
  ];
}
