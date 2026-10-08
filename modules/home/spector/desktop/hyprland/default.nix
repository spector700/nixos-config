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
    ./rules.nix
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
      configType = "lua";
      # conflicts with programs.hyprland.withUWSM in nixos
      systemd.enable = false;
      package = null;
      portalPackage = null;

      # extraConfig = ''
      #   require("dms.colors")
      # '';
    };

    modules = {
      desktop = {
        hyprpaper.enable = mkDefault false;
        hypridle.enable = mkDefault false;
        hyprlock.enable = mkDefault false;
      };
    };
  };
}
