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
    ./startup.nix
  ];
  config = mkIf cfg.hyprland.enable {
    home.packages = with pkgs; [
      grimblast
      wl-clipboard
      wlsunset
    ];

    services.cliphist.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      # conflicts with programs.hyprland.withUWSM in nixos
      systemd.enable = false;
    };

    modules = {
      desktop = {
        hyprpaper.enable = mkDefault true;
        hypridle.enable = mkDefault true;
        hyprlock.enable = mkDefault true;
      };
    };
  };
}
