{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
in
{
  options.modules.programs.thunar = {
    enable = mkEnableOption "Enable Thunar";
  };

  config = mkIf config.modules.programs.thunar.enable {
    programs.thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-volman
        thunar-archive-plugin
        thunar-media-tags-plugin
      ];
    };

    services = {
      tumbler.enable = true;
      gvfs.enable = true;
    };
  };
}
