{
  osConfig,
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkIf
    optionals
    mkEnableOption
    head
    filter
    ;
  cfg = config.modules.desktop.hyprpaper;
  # primaryWall = config.modules.theme.stylix.image;

  inherit (osConfig.modules.display) monitors;

in
# Get the name of the monitor with "primary = true"
# primaryMonitor = optionals (monitors != [ ]) (head (filter (x: x.primary or false) monitors)).name;
{
  options.modules.desktop.hyprpaper = {
    enable = mkEnableOption "Enable the hyprpaper service";
  };

  config = mkIf cfg.enable {
    services.hyprpaper = {
      enable = true;
      # settings = {
      #   preload = [ "${primaryWall}" ];
      #   wallpaper = [ "${primaryMonitor},${primaryWall}" ];
      # };
    };
  };
}
