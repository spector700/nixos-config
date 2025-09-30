{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.roles.laptop;
in
{
  options.modules.roles.laptop = {
    enable = mkEnableOption "Enable the laptop role";
  };

  # config = mkIf cfg.enable {
  # };
}
