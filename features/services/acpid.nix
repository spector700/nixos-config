_: {
  flake.aspects.acpid.nixos =
    { config, pkgs, ... }:
    {
      # Handle ACPI events such as power buttons and laptop lid changes.
      services.acpid.enable = true;

      environment.systemPackages = with pkgs; [
        acpi
        powertop
      ];

      boot = {
        kernelModules = [ "acpi_call" ];
        extraModulePackages = with config.boot.kernelPackages; [
          acpi_call
          cpupower
        ];
      };
    };
}
