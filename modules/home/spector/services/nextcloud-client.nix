{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.modules.services.nextcloud-client;
in
{
  options.modules.services.nextcloud-client = {
    enable = mkEnableOption "Enable Nextcloud Client";
  };

  config = mkIf cfg.enable {
    services.nextcloud-client = {
      enable = true;
      startInBackground = true;
    };
  };
}
