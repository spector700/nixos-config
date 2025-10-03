{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf mkDefault;
  cfg = config.modules.roles.laptop;
in
{
  options.modules.roles.laptop = {
    enable = mkEnableOption "Enable the laptop role";
  };

  config = mkIf cfg.enable {
    modules.hardware.power = {
      upower.enable = mkDefault true;
      acpid.enable = mkDefault true;
    };
  };
}
