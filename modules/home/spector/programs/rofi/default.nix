{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    theme = ./launcher-config.rasi;
  };

  stylix.targets.rofi.enable = false;
}
