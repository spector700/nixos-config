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
    firefox.enable = mkEnableOption "Enable Firefox";
    brave.enable = mkEnableOption "Enable Brave";
    zen.enable = mkEnableOption "Enable Zen Browser";
  };
  imports = [ ./firefox ];

  config = mkMerge [
    (mkIf cfg.brave.enable {
      programs.brave.enable = true;
    })
    (mkIf cfg.zen.enable {
      home.packages = with pkgs; [
        inputs.zen-browser.packages.${system}.default
      ];
    })
  ];
}
