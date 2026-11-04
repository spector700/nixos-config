{
  lib,
  config,
  ...
}:
let
  cfg = config.modules.networking.avahi;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.modules.networking.avahi = {
    enable = mkEnableOption "Enable The avahi service";
  };

  config = mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      settings.publish = {
        "disable-publishing" = false;
        "disable-user-service-publishing" = false;
        "publish-addresses" = true;
        "publish-domain" = true;
        "publish-hinfo" = true;
        "publish-workstation" = true;
      };
    };
  };
}
