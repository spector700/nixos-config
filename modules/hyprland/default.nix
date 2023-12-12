#
#  Hyprland configuration
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ ./<host>
#   │       └─ default.nix
#   └─ ./modules
#         └─ ./hyprland
#             └─ default.nix *
#

{ inputs, pkgs, user, ... }:

{
  imports = [ ../programs/waybar ];

  environment = {
    sessionVariables = {
      WLR_DRM_NO_ATOMIC = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      ANKI_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };

    systemPackages = with pkgs; [
      inputs.hyprland-contrib.packages.${pkgs.system}.grimblast
      hyprpaper
      wl-clipboard
      cliphist
      hyprpicker
      wlr-randr
      wlsunset
      xorg.xprop
    ];
  };

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

  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = [
          "gtk"
        ];
      };
    };
  };

}
