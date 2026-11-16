_: {
  flake.aspects.bluetooth.nixos =
    { config, lib, ... }:

    let
      inherit (lib) mkIf;
    in
    {
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
