{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.programs.rofi;
  inherit (lib) mkIf mkEnableOption;
in
{
  options.modules.programs.rofi = {
    enable = mkEnableOption "Enable rofi launcher";
  };

  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      theme = ./launcher-config.rasi;
    };

    stylix.targets.rofi.enable = false;
  };
}
