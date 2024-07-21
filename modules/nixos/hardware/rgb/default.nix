{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkAfter;
  cfg = config.modules.hardware;
in
{
  options.modules.hardware = {
    openrgb.enable = mkEnableOption "enable OpenRGB";
  };

  config = mkIf cfg.openrgb.enable {
    services.hardware.openrgb.enable = true;

    # Link profile
    home-manager.users.${config.modules.os.mainUser} = {
      xdg.configFile = {
        "OpenRGB/iceie.orp".source = ./iceie.orp;
      };

      # Autostart for hyprland
      wayland.windowManager.hyprland.settings = mkIf (config.modules.display.desktop == "Hyprland") {
        exec-once = mkAfter [ "sleep 5 && ${pkgs.openrgb}/bin/openrgb --profile iceie" ];
      };
    };
  };
}
