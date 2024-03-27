{ lib, config, ... }:
let
  inherit (lib) mkOption types;
  cfg = config.modules.env;
in
{
  imports = [
    ./login
    ./wayland.nix
  ];

  options.modules.env = {
    desktop = mkOption {
      type = types.enum [ "none" "Hyprland" ];
      default = "none";
      description = ''
        The desktop environment to be used.
      '';
    };

    desktops = {
      hyprland.enable = mkOption {
        type = types.bool;
        default = cfg.desktop == "Hyprland";
        description = ''
          Whether to enable Hyprland wayland compositor.

          Will be enabled automatically when `modules.env.desktop` is set to "Hyprland".
        '';
      };
    };

    isWayland = mkOption {
      type = types.bool;
      # default = with cfg.desktops; (sway.enable || hyprland.enable);
      default = with cfg.desktops; hyprland.enable;
      description = ''
        Whether to enable Wayland exclusive modules, this contains a wariety
        of packages, modules, overlays, XDG portals and so on.

        Generally includes:
          - Wayland nixpkgs overlay
          - Wayland only services
          - Wayland only programs
          - Wayland compatible versions of packages as opposed
          to the defaults
      '';
    };
  };
}
