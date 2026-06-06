{ lib, config, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;
  cfg = config.modules.display.desktop;

in
{
  imports = [
    ./login
    ./graphical.nix
    ./niri
    ./monitors.nix
    ./wayland.nix
  ];

  options.modules.display.desktop = {
    hyprland.enable = mkEnableOption "Enable the hyprland desktop";
    niri.enable = mkEnableOption "Enable the Niri desktop";

    isWayland = mkOption {
      type = types.bool;
      default = cfg.hyprland.enable || cfg.niri.enable;
      description = ''
        Whether to enable Wayland exclusive modules, this contains a wariety
        of packages, modules, overlays, XDG portals and so on.
      '';
    };

    # Add the command of each desktop for stuff like greetd
    command = mkOption {
      type = types.str;
      default = "uwsm start hyprland-uwsm.desktop";
    };
  };

  config = mkIf cfg.isWayland {
    modules.display.desktop.command =
      if cfg.hyprland.enable then
        "uwsm start hyprland-uwsm.desktop"
      else
        "${config.programs.niri.package}/bin/niri-session";
  };
}
