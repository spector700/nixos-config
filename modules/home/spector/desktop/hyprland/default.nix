{
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf mkDefault;
  cfg = osConfig.modules.display.desktop;

in
{
  imports = [
    ./binds.nix
    ./config.nix
  ];

  config = mkIf cfg.hyprland.enable {

    home.packages = with pkgs; [
      grimblast
      wl-clipboard
      wlsunset
      cliphist
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.variables = [ "--all" ];
    };

    modules = {
      desktop = {
        hyprpaper.enable = mkDefault true;
        hypridle.enable = mkDefault true;
        hyprlock.enable = mkDefault true;
      };
      theme.stylix.enable = mkDefault true;
    };
  };
}
