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

{ inputs, pkgs, user, ... }:

{
  imports = [ ../../programs/waybar ];

  environment = {

    sessionVariables = {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      LIBVA_DRIVER_NAME = "nvidia";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      __GL_GSYNC_ALLOWED = "1";
      __GL_VRR_ALLOWED = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      ANKI_WAYLAND = "1";
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      WLR_DRM_NO_ATOMIC = "1"; # For Hyprland screen tearing
      #GDK_SCALE = "2";
      #XCURSOR_SIZE = "32";
    };

    systemPackages = with pkgs; [
      inputs.hyprland-contrib.packages.${pkgs.system}.grimblast
      swaybg
      wl-clipboard
      cliphist
      hyprpicker
      wlr-randr
      wlsunset
      xorg.xprop
    ];
  };

  fonts.enableDefaultPackages = true;
  programs.dconf.enable = true;

  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
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

  # fake a tray to let apps start
  # https://github.com/nix-community/home-manager/issues/2064
  #systemd.user.targets.tray = {
  #  Unit = {
  #    Description = "Home Manager System Tray";
  #    Requires = [ "graphical-session-pre.target" ];
  #  };
  #};

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-hyprland ];
  };

}
