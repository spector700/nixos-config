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
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
    };
  };
}
