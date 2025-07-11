{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.hardware.printing;
in
{
  options.modules.hardware.printing = {
    enable = mkEnableOption "Enable Printing";
  };

  config = mkIf cfg.enable {
    services.printing = {
      # Go to the CUPS settings and add: socket://HPC85ACF1BB858.local
      enable = true;
      # drivers = with pkgs; [ hplip ];
      browsedConf = ''
        BrowseDNSSDSubTypes _cups,_print
        BrowseLocalProtocols all
        BrowseRemoteProtocols all
        CreateIPPPrinterQueues All

        BrowseProtocols all
      '';
    };
    environment.persistence."/persist".directories = mkIf config.modules.boot.impermanence.enable [
      "/var/lib/cups"
    ];
  };
}
