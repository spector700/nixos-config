{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.hardware.bluetooth;
in
{
  options.modules.hardware.bluetooth = {
    enable = mkEnableOption "Enable Bluetooth";
  };

  config = mkIf cfg.enable {
    boot.kernelParams = [ "btusb" ];

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      disabledPlugins = [ "sap" ];
      settings = {
        General = {
          JustWorksRepairing = "always";
          MultiProfile = "multiple";
        };
      };
    };

    services.blueman.enable = true;

    environment.persistence."/persist".directories = mkIf config.modules.boot.impermanence.enable [
      "/var/lib/bluetooth"
    ];
  };
}
