{ pkgs, config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.hardware.printing;
in
{
  options.modules.hardware.printing = {
    enable = mkEnableOption "Enable Printing";
  };

  config = mkIf cfg.enable {
    services = {
      printing = {
        # Go to the CUPS settings and add: socket://HPC85ACF1BB858.local
        enable = true;
        drivers = with pkgs; [ hplip ];
        browsedConf = ''
          BrowseDNSSDSubTypes _cups,_print
          BrowseLocalProtocols all
          BrowseRemoteProtocols all
          CreateIPPPrinterQueues All

          BrowseProtocols all
        '';
      };
      avahi = {
        # Needed to find wireless printer
        enable = true;
        openFirewall = true;
        nssmdns4 = true;
        publish = {
          # Needed for detecting the scanner
          enable = true;
          addresses = true;
          userServices = true;
        };
      };
    };
    environment.persistence."/persist".directories = mkIf config.modules.boot.impermanence.enable [
      "/var/lib/cups"
    ];
  };
}
