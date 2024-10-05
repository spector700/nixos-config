{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.hardware;

  profile = "iceie.orp";
in
{
  options.modules.hardware = {
    openrgb.enable = mkEnableOption "enable OpenRGB";
  };

  config = mkIf cfg.openrgb.enable {
    services.hardware.openrgb.enable = true;

    # Link profile
    environment.etc."OpenRGB/${profile}".source = ./${profile};

    # start the service
    systemd.user.services.openrgb = {
      description = "OpenRGB";
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.openrgb}/bin/openrgb --profile /etc/OpenRGB/${profile}";
      };
      restartTriggers = [ "/etc/OpenRGB/${profile}" ];
    };
  };
}
