{
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  cfg = osConfig.modules.display.desktop;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.isWayland {
    home.packages = with pkgs; [
      # Terminal Utils
      fastfetch

      # Video/Audio
      mpv
      loupe
      celluloid
      pwvucontrol

      signal-desktop
      obsidian
      anki
      vial
    ];
  };
}
