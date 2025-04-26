{
  osConfig,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = osConfig.modules.roles.video;
in
{
  config = mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      # plugins = with pkgs.stable.obs-studio-plugins; [
      #   obs-composite-blur
      #   obs-backgroundremoval
      #   obs-pipewire-audio-capture
      # ];
    };

    home.packages = with pkgs; [
      davinci-resolve
    ];
  };
}
