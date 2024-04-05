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

    isWayland = mkOption {
      type = types.bool;
      # default = with cfg.desktops; (sway.enable || hyprland.enable);
      default = cfg.desktop == "Hyprland";
      description = ''
        Whether to enable Wayland exclusive modules, this contains a wariety
        of packages, modules, overlays, XDG portals and so on.
      '';
    };
  };
}
