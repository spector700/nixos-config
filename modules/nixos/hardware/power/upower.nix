{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.hardware.power.upower;
in
{
  options.modules.hardware.power.upower = {
    enable = mkEnableOption "Enable upower service for power management";
  };

  config = mkIf cfg.enable {
    # DBus service that provides power management support to applications.
    services.upower = {
      enable = true;
      percentageLow = 15;
      percentageCritical = 5;
      percentageAction = 3;
      criticalPowerAction = "Hibernate";
    };
  };
}
