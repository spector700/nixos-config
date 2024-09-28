{ lib, config, ... }:
let
  inherit (lib)
    optionalString
    mkEnableOption
    mkOption
    types
    ;
  cfg = config.modules.display.desktop;
in
{
  imports = [
    ./login
    ./graphical.nix
    ./monitors.nix
    ./wayland.nix
  ];

  options.modules.display.desktop = {
    hyprland.enable = mkEnableOption "Enable the hyprland desktop";

    isWayland = mkOption {
      type = types.bool;
      default = cfg.hyprland.enable;
      description = ''
        Whether to enable Wayland exclusive modules, this contains a wariety
        of packages, modules, overlays, XDG portals and so on.
      '';
    };

    # Add the command of each desktop for stuff like greetd
    command = mkOption {
      type = types.str;
      default = "
        ${optionalString cfg.hyprland.enable "Hyprland"}
        ";
    };
  };
}
