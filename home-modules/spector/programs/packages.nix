{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Terminal Utils
    fastfetch

    # Video/Audio
    mpv
    loupe
    celluloid
    pavucontrol
    gimp

    signal-desktop
    nextcloud-client
    obsidian
    anki
    vial

    # File Management
    unzip
    unrar
  ];
}
