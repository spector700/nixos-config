{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.roles.desktop;
in
{
  options.modules.roles.desktop = {
    enable = mkEnableOption "Enable the Desktop role";
  };

  config = mkIf cfg.enable {

    modules = {
      networking = {
        avahi.enable = true;
        optomizeTcp = true;
      };
    };
  };
}
