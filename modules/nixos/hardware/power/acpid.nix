{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  # Pressing special keys, including the Power/Sleep/Suspend button
  # Closing a notebook lid
  # (Un)Plugging an AC power adapter from a notebook
  # (Un)Plugging phone jack etc.

  config = mkIf config.modules.roles.laptop.enable {
    # handle ACPI events
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
