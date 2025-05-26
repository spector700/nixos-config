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
      programs = {
        spicetify.enable = mkDefault true;
        zathura.enable = mkDefault true;
        orca-slicer.enable = mkDefault true;
        rofi.enable = mkDefault true;
        brave.enable = mkDefault true;
        zen.enable = mkDefault true;
      };
    };
  };
}
