{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    # Terminal Utils
    fastfetch

    # Video/Audio
    mpv
    loupe
    celluloid
    pwvucontrol
    gimp

    signal-desktop
    nextcloud-client
    obsidian
    anki
    vial
    orca-slicer
    inputs.lumastart.packages.${pkgs.system}.default
  ];
}