{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkDefault;

  cfg = config.roles.desktop;
in
{
  options.roles.desktop = {
    enable = mkEnableOption "Enable the desktop home manager config";
  };

  config = mkIf cfg.enable {
    modules = {
      theme.stylix.enable = mkDefault true;
    };
  };
}
