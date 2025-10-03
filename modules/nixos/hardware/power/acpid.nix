{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.hardware.power.acpid;
in
{
  # Pressing special keys, including the Power/Sleep/Suspend button
  # Closing a notebook lid
  # (Un)Plugging an AC power adapter from a notebook
  # (Un)Plugging phone jack etc.

  options.modules.hardware.power.acpid = {
    enable = mkEnableOption "Enable acpid service for handling ACPI events";
  };

  config = mkIf cfg.enable {
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
