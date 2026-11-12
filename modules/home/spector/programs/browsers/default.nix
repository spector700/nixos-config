{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.programs;
  inherit (lib) mkIf mkEnableOption mkMerge;
in
{
  options.modules.programs = {
    brave.enable = mkEnableOption "Enable Brave";
    zen.enable = mkEnableOption "Enable Zen Browser";
  };
  imports = [ ./firefox ];

  config = mkMerge [
    (mkIf cfg.brave.enable {
      programs.brave.enable = true;
    })
    (mkIf cfg.zen.enable {
      home.packages = [
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    })
  ];
}
