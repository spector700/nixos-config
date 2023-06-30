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

{ config, lib, pkgs, host, system, hyprland, user, ... }:
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
      #WLR_NO_HARDWARE_CURSORS="1";         # Possible variables needed in vm
      XDG_CURRENT_DESKTOP="Hyprland";
      XDG_SESSION_TYPE="wayland";
      XDG_SESSION_DESKTOP="Hyprland";
     };
     sessionVariables = {
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      __GL_GSYNC_ALLOWED = "1";
      GDK_BACKEND = "wayland";
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
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
  programs.hyprland.enable = true;
  #programs.hyprland.nvidiaPatches = true;

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
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
   };

  nixpkgs.overlays = [    # Waybar with experimental features
    (final: prev: {
      waybar = hyprland.packages.${system}.waybar-hyprland;
    })
  ];
}
