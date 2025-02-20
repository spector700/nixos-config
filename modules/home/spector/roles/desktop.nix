{
  osConfig,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkDefault;
  cfg = osConfig.modules.roles.desktop;
in
{
  config = mkIf cfg.enable {
    modules = {
      services.nextcloud-client.enable = mkDefault true;
      theme.stylix.enable = mkDefault true;
      programs.spicetify.enable = mkDefault true;
      programs.orca-slicer.enable = mkDefault true;
    };
  };
}
