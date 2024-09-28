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
  cfg = config.modules.desktops.hyprpaper;
  primaryWall = config.modules.theme.wallpaper;

  inherit (osConfig.modules.display) monitors;

  # Get the name of the monitor with "primary = true"
  primaryMonitor = optionals (monitors != [ ]) (head (filter (x: x.primary or false) monitors)).name;
in
{
  options.modules.desktops.hyprpaper = {
    enable = mkEnableOption "Enable the hyprpaper service";
  };

  config = mkIf cfg.enable {
    services.hyprpaper = {
      enable = true;
      settings = {
        preload = [ "${primaryWall}" ];
        wallpaper = [ "${primaryMonitor},${primaryWall}" ];
      };
    };
  };
  # xdg.configFile."hypr/hyprpaper.conf".text = ''
  #   preload = ${config.modules.theme.wallpaper}
  #   wallpaper = , ${config.modules.theme.wallpaper}
  # '';
  #
  # systemd.user.services.hyprpaper = {
  #   Unit = {
  #     Description = "Hyprland wallpaper daemon";
  #     PartOf = [ "graphical-session.target" ];
  #   };
  #   Service = {
  #     ExecStart = "${lib.getExe pkgs.hyprpaper}";
  #     Restart = "on-failure";
  #   };
  #   Install.WantedBy = [ "graphical-session.target" ];
  # };
}
